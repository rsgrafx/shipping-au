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

  alias Sendle.Requests.CreateOrder

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
  @spec get_campaign(params :: integer | Keyword.t()) :: Campaign.t()
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

  @spec process_orders(
          campaign :: Campaign.t(),
          params :: map()
        ) :: {:ok, [map()]}
  def process_orders(campaign, request_data) do
    {_, %{data: request_data}} = atomize(request_data)

    results =
      Enum.map(campaign.participants, fn inflcer ->
        Enum.filter(request_data.participants, &(&1.influencer_id == inflcer.influencer_id))
        |> case do
          [] -> :error_none_found
          [address_data] -> order_request_payload(inflcer, address_data)
        end
      end)

    {:ok, results}
  end

  @spec send_requests(order_lists :: [map()]) :: {:ok, [map()]} | {:error, any()}
  def send_requests(order_lists) do
    {:ok,
     Enum.map(order_lists, fn order_payload ->
       CreateOrder.request(order_payload)
     end)}
  end

  @doc """
   Builds list of payloads to send to Sendle.
  """
  def order_request_payload(influencer, packing_data, sender \\ :au) do
    packing_data =
      case packing_data.description do
        info when is_nil(info) when info == "" ->
          %{packing_data | description: "No additional description given"}

        _ ->
          packing_data
      end

    payload = %{
      sender: warehouse(sender),
      receiver: %{
        instructions: influencer.note_for_shipper || "No additional instructions given",
        contact: %{
          name: influencer.full_name,
          email: influencer.email,
          company: ""
        },
        address: %{
          address_line1: influencer.address.address_line1,
          suburb: influencer.address.city,
          state_name: influencer.address.state_name,
          postcode: influencer.address.postcode,
          country: influencer.address.country
        }
      }
    }

    Map.merge(payload, packing_data)
  end

  def load_products(rollout_id) do
    from(pp in ProductParticipant,
      join: product in assoc(pp, :campaign_product),
      where: pp.campaign_rollout_id == ^rollout_id,
      select: product
    )
  end

  def build_response(campaign, responses) do
    %{campaign | packing_slips: Enum.map(responses, &pluck_sendle_data/1)}
  end

  defp pluck_sendle_data(%{status: 201} = data) do
    %{
      influencer_id: nil,
      sendle:
        Map.take(data.body, [
          "order_id",
          "order_url",
          "price",
          "route",
          "sendle_reference",
          "tracking_url"
        ])
    }
  end

  defp pluck_sendle_data(data) do
    %{error: data.body}
  end

  def warehouse(sender_key, instructions \\ "No instructions supplied by receiver") do
    vamp_address_locations = %{
      au: %{
        contact: %{name: "Admin", phone: "61 1300 606 614", company: "Vamp.me"},
        address: %{
          address_line1: "50 King Street",
          suburb: "Sydney",
          state_name: "NSW",
          postcode: "2000",
          country: "Australia"
        },
        instructions: instructions
      }
    }

    Map.get(vamp_address_locations, sender_key)
  end
end
