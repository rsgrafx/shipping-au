defmodule SendleWeb.ApiTest do
  use Sendle.ConnCase

  # Creating the Picking List.

  setup do
    payload = File.read!("test/support/fixture/incoming_requests/sendle-request-payload.json")
    url = Application.get_env(:sendle, :url)
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
  describe "POST /sendle/campaign/:campaign_id/process" do
    test "Call to this endpoint should trigger calls to process orders with Sendle"
    test "Call to this endpoint should return - processed payload"
    test "When processing this list order for each mailing should be stored to db"
    test "Call to this endpoint should return sendle order list"
    test "Each object in this list should contain order code"
  end
end
