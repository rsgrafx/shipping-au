defmodule Sendle.Campaigns.Process do
  @moduledoc """
  House logic that handles processing orders via Sendle.API
  """
  require Logger
  use Sendle.Schema

  alias Sendle.Requests.{CreateOrder, ShippingOrders}
  alias Sendle.Campaigns.Store
  alias Sendle.Campaigns

  @spec process_orders(
          campaign :: Campaign.t(),
          params :: map()
        ) :: {:ok, [map()]}
  def process_orders(campaign, request_data) do
    {_, %{data: request_data}} = atomize(request_data, Poison)

    results =
      Enum.reduce(campaign.participants, [], fn infl, acc ->
        result = Enum.filter(request_data.participants, &(&1.influencer_id == infl.influencer_id))

        case result do
          [] ->
            acc

          [address_data] ->
            payload = order_request_payload(infl, address_data)
            [payload | acc]
        end
      end)

    {:ok, results}
  end

  alias Sendle.HTTP.{Response, RequestError}

  @spec get_labels(order :: map()) :: map()
  def get_labels(order) do
    ShippingOrders.get_by_id(order.order_id)
  end

  @spec send_requests(order_lists :: [map()]) :: {:ok, [map()]}
  def send_requests(order_lists) do
    order_lists
    |> build_tasks()
    |> check_tasks([])
  end

  defp check_tasks([], results) do
    {:ok, results}
  end

  defp check_tasks([{order, %Response{} = response} | tail], values) do
    %{body: body, status: status} = result = Map.take(response, [:body, :status])

    if status == 201 do
      Store.save_response(order.influencer_id, order.campaign_id, body)
    end

    result = %{result | body: set_influencer(body, order.influencer_id)}

    check_tasks(tail, [result | values])
  end

  defp check_tasks([{order, %{} = response} | tail], values) do
    %{body: body} = result = Map.take(response, [:body, :status])

    result = %{result | body: set_influencer(body, order.influencer_id)}
    check_tasks(tail, [result | values])
  end

  defp check_tasks([{_, %Task{}} | _tail] = list, values) do
    check_tasks(Enum.reverse(list), values)
  end

  defp set_influencer(nil, influencer_id) do
    Map.merge(%{"influencer_id" => influencer_id}, %{"error" => "Nil response from API"})
  end

  defp set_influencer(body, influencer_id) do
    Map.merge(%{"influencer_id" => influencer_id}, body)
  end

  defp build_tasks(order_lists) do
    Enum.map(order_lists, fn order ->
      task = Task.async(fn -> CreateOrder.request(order) end)
      {order, wait_and_return(order, task)}
    end)
  end

  @bad_request %{
    body: %{
      error: "Was not able to process order - something went wrong processing one of the orders."
    },
    status: 500
  }
  def wait_and_return(order, task) do
    try do
      Task.await(task)
    catch
      :exit, _ ->
        Logger.warn("Could not process requests Influencer: #{order.influencer_id}")
        @bad_request
    end
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
      sender: Campaigns.warehouse(sender),
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
end
