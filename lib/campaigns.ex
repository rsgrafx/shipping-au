defmodule Sendle.Campaigns do
  @moduledoc """
  Houses logic to start campaigns, processing incoming requests to
    build picking_lists and packing slips
  """

 alias Sendle.Campaigns.{
   Fetch,
   Process,
   Store
 }

  defdelegate get_campaign(params), to: Fetch
  defdelegate create(payload), to: Store
  defdelegate mark_as_processed(campaign_id), to: Store

  defdelegate process_orders(campaign, request_data), to: Process
  defdelegate send_requests(order_lists), to: Process
  defdelegate build_response(campaign, response), to: Process

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
