defmodule Sendle.Campaigns.Fetch do
  @moduledoc """
  House logic that fetches Campaigns from data store.
  """

  use Sendle.Schema

  @doc """
    Fetch Campaign.  From database
  """
  @spec get_campaign(params :: integer | Keyword.t()) :: Campaign.t()
  def get_campaign(params) do
    case do_get_campaign(params) do
      nil ->
        :error_not_found

      campaign_rollout ->
        Campaign.new(campaign_rollout)
    end
  end

  defp do_get_campaign(rollout_id) when is_integer(rollout_id) do
    CampaignRollout
    |> Repo.get(rollout_id)
    |> preload()
  end

  defp do_get_campaign(campaign_id: id) do
    query =
      from(cr in CampaignRollout,
        where: cr.campaign_id == ^id,
        order_by: [desc: cr.inserted_at],
        limit: 1
      )

    case Repo.all(query) do
      [] -> nil
      [campaign] -> preload(campaign)
    end
  end

  defp preload(campaign) do
    Repo.preload(campaign, [
      :products,
      participants: [
        :sendle_responses,
        [products: load_products(campaign.id)]
      ]
    ])
  end

  defp load_products(rollout_id) do
    from(pp in ProductParticipant,
      join: product in assoc(pp, :campaign_product),
      where: pp.campaign_rollout_id == ^rollout_id,
      select: product
    )
  end
end
