defmodule Sendle.CampaignsTest do
  use Sendle.DataCase

  alias Sendle.SchemaFactory, as: SF

  @payload_file "test/support/fixture/incoming_requests/sendle-request-payload.json"

  describe "create/1" do
    setup do
      payload =
        @payload_file
        |> File.read!()
        |> Poison.decode!(keys: :atoms)

      {:ok, payload: payload}
    end

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
             } = Campaigns.create(payload)

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
  end

  describe "save/1" do
    setup do
      payload =
        @payload_file
        |> File.read!()
        |> Poison.decode!()

      {:ok, payload: payload}
    end

    test "retrieves participants from database referencing campaign_id", %{
      payload: payload
    } do
      # Given a request has been submitted.
      # A Vamp team member should be able to access PickingList.

      campaign =
        payload
        |> Campaigns.create()
        |> Campaigns.save()

      alias Sendle.Schemas.{CampaignRollout, CampaignParticipant}

      assert [campaign] =
               CampaignRollout
               |> Repo.all()
               |> Repo.preload(:participants)

      assert campaign.name == "Lulumon Leggings Campaign Fall 2018"
      # todo:
      assert campaign.campaign_id == 100
      assert campaign.instructions == "Missing some small tags"
    end

    test "retrieves products from database referencing campaign_id", %{payload: payload} do
      campaign_rollout = SF.insert(:campaign_rollout)

      campaign_id = campaign_rollout.campaign_id

      alias Sendle.Schemas.{CampaignRollout, CampaignParticipant}

      assert %Campaign{campaign_id: ^campaign_id, participants: influencers, products: products} =
               Campaigns.get_campaign(campaign_id: campaign_rollout.campaign_id)

      #
      assert is_list(influencers)
      assert %Participant{} = List.first(influencers)
      assert is_list(products)
      assert %Product{} = List.first(products)
    end
  end
end
