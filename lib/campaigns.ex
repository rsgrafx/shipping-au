defmodule Sendle.Campaigns do
  @moduledoc """
  Houses logic to start campaigns, processing incoming requests to
    build picking_lists and packing slips
  """

  import Ecto.Query

  alias Sendle.Campaigns.Campaign

  alias Sendle.Schemas.{
    CampaignRollout,
    CampaignParticipant,
    ProductParticipant
  }

  alias Sendle.Repo

  @type campaign :: Campaign.t()

  @doc """
    Entry Point for system.
  """
  @spec create(payload :: map()) :: campaign
  def create(%{"data" => _data} = data) do
    with {:ok, payload} <- atomize(data) do
      create(payload)
    else
      _ -> {:error, :cannot_decode_payload}
    end
  end

  def create(%{data: data} = payload) when is_map(payload) do
    Campaign.new(data)
  end

  defp atomize(%{"data" => _} = data) do
    data
    |> Poison.encode!()
    |> Poison.decode(keys: :atoms)
  end

  defp atomize(%{data: _} = data) do
    data
  end

  @doc """
    Takes a Campaign.t as a parameter
     - Saves
     - saves CampaignParticipant.t records
  """
  @spec save(campaign :: Campaign.t()) :: map()
  def save(campaign) do
    campaign_rollout =
      campaign
      |> CampaignRollout.build()
      |> CampaignRollout.changeset()
      |> Sendle.Repo.insert!()

    participants =
      Enum.map(
        campaign.participants,
        &build_participant(Map.merge(&1, %{campaign_id: campaign_rollout.id}))
      )

    %{campaign: campaign_rollout, participants: participants}
  end

  defp build_participant(params) do
    params
    |> CampaignParticipant.build()
    |> CampaignParticipant.changeset()
  end

  @doc """
    Fetch Campaign.  From database
  """
  @spec get_campaign(params :: integer | Keyword.t()) :: CampaignRollout.t()
  def get_campaign(params) do
    case do_get_campaign(params) do
      nil ->
        :error_not_found

      campaign_rollout ->
        Campaign.new(campaign_rollout)
    end
  end

  def do_get_campaign(rollout_id) when is_integer(rollout_id) do
    CampaignRollout
    |> Repo.get(rollout_id)
    |> preload()
  end

  def do_get_campaign(campaign_id: id) do
    CampaignRollout
    |> Repo.get_by(campaign_id: id)
    |> preload()
  end

  defp preload(campaign) do
    Repo.preload(campaign, [:products, participants: [products: load_products(campaign.id)]])
  end

  @spec process_request(params :: map()) :: CampaignRollout.t()
  def process_request(%{"campaign_id" => campaign_id} = data) do
    {_, data} = atomize(data)

    case do_get_campaign(campaign_id: campaign_id) do
      %CampaignRollout{} = campaign -> campaign
      _ -> :error
    end
  end

  def load_products(rollout_id) do
    from(pp in ProductParticipant,
      join: product in assoc(pp, :campaign_product),
      where: pp.campaign_rollout_id == ^rollout_id,
      select: product
    )
  end
end
