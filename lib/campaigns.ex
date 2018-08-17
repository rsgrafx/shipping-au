defmodule Sendle.Campaigns do
  @moduledoc """
  Houses logic to start campaigns, processing incoming requests to
    build picking_lists and packing slips
  """

  alias Sendle.Campaigns.Campaign
  alias Sendle.Schemas.{CampaignRollout, CampaignParticipant}

  @type campaign :: Campaign.t()

  @doc """
    Entry Point for system.
  """
  def create(payload) when is_binary(payload) do
    with {:ok, payload} <- Poison.decode(payload, keys: :atoms) do
      create(payload)
    else
      _ -> {:error, :cannot_decode_payload, payload}
    end
  end

  @spec create(payload :: map()) :: campaign
  def create(%{data: data} = payload) when is_map(payload) do
    Campaign.new(data)
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
end
