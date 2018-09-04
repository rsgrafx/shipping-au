defmodule Sendle.Campaigns.Process do
  @moduledoc """
  House logic that handles processing orders via Sendle.API
  """
  require Logger
  use Sendle.Schema

  alias Sendle.Requests.CreateOrder
  alias Sendle.Campaigns.Store
  alias Sendle.Campaigns

  @spec process_orders(
          campaign :: Campaign.t(),
          params :: map()
        ) :: {:ok, [map()]}
  def process_orders(campaign, request_data) do
    {_, %{data: request_data}} = atomize(request_data, Poison)

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

  @bad_request %{
    body: %{
      error: "Was not able to process order - something went wrong processing one of the orders."
    },
    status: 500
  }
  @spec send_requests(order_lists :: [map()]) :: {:ok, [map()]} | {:error, any()}
  def send_requests(order_lists) do
    results =
      order_lists
      |> build_tasks()
      |> Enum.map(fn
        {:error_none_found, _} ->
          @bad_request

        {order, task} ->
          %{body: body} = result = Map.take(wait_and_return(order, task), [:body, :status])

          body =
            if is_nil(body) do
              Map.merge(%{"influencer_id" => order.influencer_id}, %{
                "error" => "Nil response from API"
              })
            else
              Map.merge(%{"influencer_id" => order.influencer_id}, body)
            end

          if result.status == 201 do
            Store.save_response(order.influencer_id, order.campaign_id, body)
          end

          %{result | body: body}
      end)

    {:ok, results}
  end

  defp build_tasks(order_lists) do
    Enum.map(order_lists, fn payload ->
      {payload, Task.async(fn -> CreateOrder.request(payload) end)}
    end)
  end

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
