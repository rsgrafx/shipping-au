defmodule SendleWeb.ApiTest do
  use Sendle.ConnCase

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  # Creating the Picking List.

  setup do
    payload = File.read!("test/support/fixture/incoming_requests/sendle-request-payload.json")
    url = Application.get_env(:sendle, :url)
    ExVCR.Config.cassette_library_dir("test/support/fixture/vcr_cassettes")
    {:ok, payload: payload, http_url: url}
  end

  describe "POST /sendle/campaigns" do
    test "Endpoint should receive payload and create records", %{payload: payload} do
      result =
        build_conn()
        |> put_req_header("content-type", "application/json")
        |> post("/sendle/campaigns", payload)

      assert result = json_response(result, 200)

      assert %{
               "data" => %{"status" => "accepted"}
             } = Poison.decode!(result)
    end

    test "Endpoint should return error code payload malformed"
  end

  describe "GET /sendle/campaigns/:campaign_id" do
    test "should return 200 - for new campaign" do
      campaign = SchemaFactory.insert(:campaign_rollout)
      [product] = campaign.products

      Enum.map(campaign.participants, fn person ->
        SchemaFactory.insert(:assigned_product,
          campaign_rollout_id: campaign.id,
          campaign_rollout: nil,
          campaign_product_id: product.id,
          campaign_participant_id: person.id
        )
      end)

      campaign_id = campaign.campaign_id
      name = campaign.name

      result =
        build_conn()
        |> put_req_header("content-type", "application/json")
        |> get("/sendle/campaigns/#{campaign.campaign_id}")

      assert result = json_response(result, 200)

      assert %{
               "data" => %{
                 "campaign_id" => ^campaign_id,
                 "campaign_name" => ^name,
                 "status" => "new",
                 "instructions" => _,
                 "packing_slips" => nil,
                 "participants" => participants
               }
             } = result

      assert is_list(participants)

      for influencer <- participants do
        assert %{
                 "influencer_id" => _,
                 "products" => assigned_products
               } = influencer

        assert is_list(assigned_products)

        assert [
                 %{
                   "campaign_product_id" => _,
                   "quantity" => quantity,
                   "size" => size,
                   "sku" => _
                 }
               ] = assigned_products

        assert is_number(quantity)
        assert is_number(size)
      end
    end

    test "should return 404 - for campaign not in system." do
      result =
        build_conn()
        |> put_req_header("content-type", "application/json")
        |> get("/sendle/campaigns/foobar")

      assert result = json_response(result, 404)

      assert %{
        "data" => %{
          "error" => "Campaign not found"
        }
      }
    end
  end

  # Picking List and processing.
  describe "PUT /sendle/campaign/:campaign_id/process" do
    test "Call to this endpoint should trigger calls to process orders with Sendle" do
      Application.put_env(:sendle, :api_credentials, %{
        api_endpoint: "https://sandbox.sendle.com",
        sendle_auth_id: System.get_env("TEST_SENDLE_ID"),
        sendle_api_key: System.get_env("TEST_SENDLE_API_KEY")
      })

      campaign = SchemaFactory.insert(:campaign_rollout)
      [product] = campaign.products

      Enum.map(campaign.participants, fn person ->
        SchemaFactory.insert(:assigned_product,
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

      use_cassette "order_requests_all" do
        result =
          build_conn()
          |> put_req_header("content-type", "application/json")
          |> put("/sendle/campaigns/#{campaign.campaign_id}/process", data)

        assert json_response(result, 201)

        assert %{
                 "data" => %{
                   "packing_slips" => packing_slips
                 }
               } = Poison.decode!(result.resp_body)

        assert is_list(packing_slips)

        for package_data <- packing_slips do
          assert %{
                   "influencer_id" => in_id,
                   "sendle" => %{
                     "sendle_reference" => _code,
                     "price" => cost,
                     "order_id" => _uuid,
                     "order_url" => _,
                     "tracking_url" => _
                   }
                 } = package_data
          assert is_integer(in_id)
        end
      end
    end

    test "When processing this list order for each mailing should be stored to db"
  end
end
