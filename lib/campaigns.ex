defmodule Sendle.Campaigns do
  @moduledoc """
  Houses logic to start campaigns, processing incoming requests to
    build picking_lists and packing slips
  """

  import Ecto.Query

  alias Sendle.Campaigns.Campaign

  alias Sendle.Schemas.{
    CampaignRollout,
    CampaignProduct,
    CampaignParticipant,
    ProductParticipant,
    SendleResponse
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
    campaign =
      Campaign.new(data)

    save(campaign)
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

    saved_products = Enum.map(campaign.products, &build_product(campaign_rollout, &1))

    participants =
      Enum.map(
        campaign.participants,
        fn influencer ->
          data =
            Map.merge(influencer, %{
              campaign: campaign_rollout,
              campaign_id: campaign_rollout.campaign_id
            })

          participant = build_participant(data)
          build_participant_product(participant, influencer.products, saved_products)
        end
      )

    %{
      campaign: campaign_rollout,
      participants: participants,
      products: saved_products
    }
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
      if (assigned.campaign_product_id in Enum.map(products, & &1.campaign_product_id)) do
        _ =
          Repo.insert!(%ProductParticipant{
            campaign_participant_id: participant.id,
            campaign_product_id: assigned.campaign_product_id,
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
    results =
      Enum.map(order_lists, fn payload ->
        {payload, Task.async(fn -> CreateOrder.request(payload) end)}
      end)
      |> Enum.map(fn {order, task} ->
        %{body: body} = result = Map.take(Task.await(task), [:body, :status])

        body = Map.merge(%{"influencer_id" => order.influencer_id}, body)

        if result.status == 201 do
          _ = save_response(order.influencer_id, body)
        end

        %{result | body: body}
      end)

    {:ok, results}
  end

  @doc """
  Save response to `sendle_responses` table.
  """
  @spec save_response(integer(), map()) ::
          {:ok, Ecto.Schema.t()} | {:error, :cant_find_campaign_participant}
  def save_response(influencer_id, sendle_response) do
    case do_get_campaign_participant(influencer_id) do
      nil ->
        {:error, :cant_find_campaign_participant}

      participant ->
        participant
        |> Ecto.build_assoc(:sendle_responses)
        |> SendleResponse.changeset(sendle_response)
        |> Repo.insert()
    end
  end

  defp do_get_campaign_participant(influencer_id) do
    Repo.get_by(CampaignParticipant, influencer_id: influencer_id)
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
    %{body: %{"influencer_id" => infl_id}} = data

    %{"influencer_id" => infl_id}
    |> Map.merge(
      Map.take(data.body, [
        "order_id",
        "order_url",
        "price",
        "route",
        "sendle_reference",
        "tracking_url",
        "state",
        "scheduling"
      ])
    )
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
