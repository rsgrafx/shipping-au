defmodule Sendle.Campaigns do
  use ExUnit.Case

  alias Sendle.Campaigns.Rollout

  alias Sendle.Campaigns.{
    Address,
    Campaign,
    Participant,
    Product
  }

  setup_all do
    payload = File.read!("test/support/fixture/incoming_requests/sendle-request-payload.json")
    {:ok, payload: payload}
  end

  describe "create/1" do
    test "recieves product and participants payload and returns valid data structures", %{
      payload: payload
    } do
      sender_contact = %{
        name: "Admin",
        phone: "61 1300 606 614",
        company: "Vamp.me"
      }

      sender_address = %{
        address_line1: "50 King Street",
        city: "Sydney",
        state_name: "NSW",
        postcode: "2000",
        country: "Australia"
      }

      assert %Campaign{
               campaign_id: 100,
               participants: participants,
               products: products,
               sender: %{
                 contact: ^sender_contact,
                 address: ^sender_address,
                 instructions: ""
               }
             } = data = Rollout.create(payload)

      assert %Participant{
               email: "",
               address: %Address{
                 city: "North Sydney",
                 postcode: "2060",
                 country: "Australia",
                 state_name: "NSW",
                 address_line1: "Level 1",
                 address_line2: "17 Jones St"
               },
               full_name: "Ms. Jane Doe",
               note_for_shipper: "",
               quantity: nil,
               shipping_size: nil,
               shipping_weight: nil
             } = List.first(participants)

      assert %Product{} = List.first(products)
    end

    test "retrieves product and participants from database referencing campaign_id"

    test "can retrieve"
  end
end
