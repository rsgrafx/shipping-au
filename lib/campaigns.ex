defmodule Sendle.Campaigns do
  @moduledoc """
  Houses logic to start campaigns, processing incoming requests to
    build picking_lists and packing slips
  """

  alias Sendle.Campaigns.Campaign
  alias Sendle.Schemas.{CampaignRollout, CampaignParticipant}
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
  @spec get_campaign(params :: integer | Keyword.t()) :: CampainRollout.t()
  def get_campaign(params) do
    result = do_get_campaign(params)

    case result do
      nil ->
        :error_not_found

      campaign_rollout ->
        Campaign.new(campaign_rollout)
    end
  end

  def do_get_campaign(id) when is_integer(id) do
    CampaignRollout
    |> Repo.get(id)
    |> Repo.preload([:participants, :products])
  end

  def do_get_campaign(campaign_id: id) when is_integer(id) do
    CampaignRollout
    |> Repo.get_by(campaign_id: id)
    |> Repo.preload([:participants, :products])
  end
end
