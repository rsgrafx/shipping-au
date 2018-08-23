defmodule Sendle.Requests.CreateOrderTest do
  use Sendle.HTTPClientCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Sendle.Requests.CreateOrder

  setup do
    ExVCR.Config.cassette_library_dir("test/support/fixture/vcr_cassettes")
    :ok
  end

  describe "create_order_request/1" do
    setup do
      Application.put_env(:sendle, :api_credentials, %{
        api_endpoint: "https://sandbox.sendle.com",
        sendle_auth_id: System.get_env("TEST_SENDLE_ID"),
        sendle_api_key: System.get_env("TEST_SENDLE_API_KEY")
      })
      :ok
    end

    test "Returns 401 with incorrect credentials /api/orders" do
      request = Sendle.JSONFactory.build(:create_order)

      use_cassette "incorrect_credentials" do
        assert %Sendle.HTTP.RequestError{
          body: _,
          code: "unauthorised",
          message: "The authorisation details are not valid. Either the Sendle ID or API key are incorrect.",
          status: 401
        } = CreateOrder.request(request)
      end
    end

    test "missing details when submitting request" do
      request = Sendle.JSONFactory.build(:create_order)

      use_cassette "missing_details_order" do
        assert %Sendle.HTTP.RequestError{
          body: _,
          code: "unprocessable_entity",
          message: "The data you supplied is invalid. Error messages are in the messages section. Please fix those fields and try again.",
          status: 422
        } = CreateOrder.request(request)
      end
    end

    test "successful request should return data in body" do
      request = Sendle.JSONFactory.build(:create_order)

      use_cassette "create_order" do
        assert %Sendle.HTTP.Response{
          body: _,
          status: 201,
          response_headers: _
        } = CreateOrder.request(request) |> IO.inspect()
      end
    end
  end
end
