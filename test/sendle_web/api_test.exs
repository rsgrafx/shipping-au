defmodule SendleWeb.ApiTest do
  use ExUnit.Case, async: true
  use Plug.Test

  # Creating the Picking List.
  describe "POST /sendle/campaign/rollout" do
    test "Endpoint should receive payload and create records"
    test "Endpoint should return error code payload malformed"
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
