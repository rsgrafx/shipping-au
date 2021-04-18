defmodule Sendle.CampaignsTest do
  use Sendle.DataCase

  alias Sendle.SchemaFactory, as: SF
  alias Sendle.Campaigns.Campaign
  alias Sendle.Schemas.CampaignRollout

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
        company: "AcmeCo"
      }

      sender_address = %{
        address_line1: "50 King Street",
        suburb: "Sydney",
        state_name: "NSW",
        postcode: "2000",
        country: "Australia"
      }

      assert {:ok,
              %Campaign{
                campaign_id: 100,
                participants: participants,
                products: products,
                sender: %{
                  contact: ^sender_contact,
                  address: ^sender_address,
                  instructions: "No instructions supplied by receiver"
                }
              }} = Campaigns.create(payload)

      assert %Participant{
               email: _,
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
      # A AcmeCo team member should be able to access PickingList.
      payload
      |> Campaigns.create()

      assert [campaign] =
               CampaignRollout
               |> Repo.all()
               |> Repo.preload(:participants)

      assert campaign.name == "Lulumon Leggings Campaign Fall 2018"
      # todo:
      assert campaign.campaign_id == 100
      assert campaign.instructions == "Missing some small tags"
    end

    test "retrieves products from database referencing campaign_id" do
      campaign_rollout = SF.insert(:campaign_rollout)

      campaign_id = campaign_rollout.campaign_id

      assert %Campaign{campaign_id: ^campaign_id, participants: influencers, products: products} =
               Campaigns.get_campaign(campaign_id: campaign_rollout.campaign_id)

      #
      assert is_list(influencers)
      assert %Participant{} = List.first(influencers)
      assert is_list(products)
      assert %Product{} = List.first(products)
    end
  end

  describe "process_orders/2" do
    setup do
      campaign = SF.insert(:campaign_rollout)
      [product] = campaign.products

      Enum.map(campaign.participants, fn person ->
        SF.insert(:assigned_product,
          campaign_rollout_id: campaign.id,
          campaign_rollout: nil,
          campaign_product_id: product.id,
          campaign_participant_id: person.id
        )
      end)

      data =
        %{
          data: %{
            participants:
              Enum.map(campaign.participants, fn influencer ->
                %{
                  pickup_date: "2018-09-24",
                  influencer_id: influencer.influencer_id,
                  description: "",
                  kilogram_weight: "1",
                  cubic_metre_volume: "0.01",
                  customer_reference: "Nothing to say.",
                  meta_data: %{}
                }
              end)
          }
        }
        |> Poison.encode!()
        |> Poison.decode!()

      {:ok, campaign: campaign, request: data}
    end

    test "requests persisted campaign rollout data and builds `Campaign` module", %{
      campaign: campaign,
      request: request
    } do
      campaign = Sendle.Campaigns.get_campaign(campaign.id)
      assert {:ok, order_requests} = Sendle.Campaigns.process_orders(campaign, request)
      assert is_list(order_requests)

      for influencer <- order_requests do
        %{
          cubic_metre_volume: "0.01",
          customer_reference: "Nothing to say.",
          description: "No additional description given",
          influencer_id: _,
          kilogram_weight: "1",
          meta_data: %{},
          pickup_date: "2018-09-24",
          receiver: %{
            address: %{
              address_line1: _address_one,
              country: "Australia",
              postcode: "2000",
              state_name: "NSW",
              suburb: "Sydney"
            },
            contact: %{
              company: "",
              email: _,
              name: _
            }
          },
          sender: %{
            address: %{
              address_line1: "50 King Street",
              suburb: "Sydney",
              country: "Australia",
              postcode: "2000",
              state_name: "NSW"
            },
            contact: %{company: "AcmeCo", name: "Admin", phone: "61 1300 606 614"},
            instructions: "No instructions supplied by receiver"
          }
        } = influencer
      end
    end
  end
end
