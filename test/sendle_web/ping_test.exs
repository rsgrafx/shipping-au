defmodule SendleWeb.PingTest do
  use Sendle.ConnCase

  describe "/ping" do
    test "returns success" do
      response =
        build_conn()
        |> put_req_header("content-type", "application/json")
        |> put_req_header("accept", "application/json")
        |> get("/ping")

      assert json_response(response, 200)
    end
  end
end
