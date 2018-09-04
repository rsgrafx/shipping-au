defmodule Sendle.Campaigns.Store do
  @moduledoc """
  House logic that pushes data to the Data store.
  """

  use Sendle.Schema

  @type campaign :: Campaign.t()

  @doc """
    Entry Point for system.
  """
  @spec create(payload :: map()) :: {:ok, campaign}
  def create(%{"data" => _data} = data) do
    with {:ok, payload} <- atomize(data, Poison) do
      create(payload)
    else
      _ -> {:error, :cannot_decode_payload}
    end
  end

  def create(%{data: data} = payload) when is_map(payload) do
    campaign = Campaign.new(data)

    save(campaign)
  end

  @doc """
    Takes a Campaign.t as a parameter
     - Saves
     - saves CampaignParticipant.t records
  """
  @spec save(campaign :: Campaign.t()) :: map()
  def save(campaign) do
    campaign_rollout = insert_campaign_rollout(campaign)
    saved_products = Enum.map(campaign.products, &build_product(campaign_rollout, &1))

    Enum.map(
      campaign.participants,
      fn influencer ->
        data =
          Map.merge(influencer, %{
            campaign: campaign_rollout,
            campaign_id: campaign_rollout.campaign_id
          })

        data
        |> build_participant()
        |> build_participant_product(influencer.products, saved_products)
      end
    )

    {:ok, campaign}
  end

  defp insert_campaign_rollout(campaign) do
    campaign
    |> CampaignRollout.build()
    |> CampaignRollout.changeset()
    |> Sendle.Repo.insert!()
  end

  defp build_product(campaign, product) do
    data =
      product
      |> Map.merge(%{product_name: product.name})
      |> Map.from_struct()

    campaign
    |> Ecto.build_assoc(:products, data)
    |> CampaignProduct.changeset(data)
    |> Repo.insert!()
  end

  defp build_participant_product(participant, assigned_products, products) do
    Enum.map(assigned_products, fn assigned ->
      case Enum.filter(products, &(&1.campaign_product_id == assigned.campaign_product_id)) do
        [] ->
          :noop

        [product] ->
          Repo.insert!(%ProductParticipant{
            campaign_participant_id: participant.id,
            campaign_product_id: product.id,
            campaign_rollout_id: participant.campaign_rollout_id
          })
      end
    end)
  end

  defp build_participant(params) do
    params
    |> CampaignParticipant.build()
    |> CampaignParticipant.changeset()
    |> Repo.insert!()
  end


  @doc """
  Save response from Sendle after a successful process to `sendle_responses` table.
  """
  @spec save_response(integer(), integer(), map()) ::
          {:ok, Ecto.Schema.t()} | {:error, :cant_find_campaign_participant}
  def save_response(influencer_id, campaign_id, sendle_response) do
    case do_get_campaign_participant(influencer_id, campaign_id) do
      [participant] ->
        participant
        |> Ecto.build_assoc(:sendle_responses)
        |> SendleResponse.changeset(sendle_response)
        |> Repo.insert()

      _ ->
        {:error, :cant_find_campaign_participant}
    end
  end

  defp do_get_campaign_participant(influencer_id, campaign_id) do
    from(cp in CampaignParticipant,
      where: cp.influencer_id == ^influencer_id and cp.campaign_id == ^campaign_id,
      order_by: [desc: cp.inserted_at],
      limit: 1
    )
    |> Repo.all()
  end

  @doc "Mark CampaignRollout as processed"
  def mark_as_processed(campaign_id) do
    cr = Repo.get_by(CampaignRollout, campaign_id: campaign_id)
    case cr do
      nil -> :error_not_found
      %{} = rollout ->
        changeset = CampaignRollout.status_changeset(rollout, %{status: "processed"})
        Repo.update(changeset)
    end
  end

end
