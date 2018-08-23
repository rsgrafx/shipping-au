defmodule Sendle.Requests.QuoteTest do
  use Sendle.HTTPClientCase

  alias Sendle.Requests.Quote

  @unauth File.read!("test/support/fixture/api_stubs/quote_unauthorized.json")

  @valid File.read!("test/support/fixture/api_stubs/quote.json")
  # @creds Sendle.get_api_credentials()

  setup do
    Application.put_env(:sendle, :api_credentials, %{
      api_endpoint: "http://localhost:8383",
      sendle_auth_id: System.get_env("TEST_SENDLE_ID"),
      sendle_api_key: System.get_env("TEST_SENDLE_API_KEY")
    })
    :ok
  end

  describe "new/1" do
    test "with proper params should return `Quote` struct" do
      quotation =
        Quote.new(%{
          from: ["Camberwell North", "3214"],
          to: ["Barangaroo", "2000"],
          weight: 2,
          size: 0.01
        })

      assert is_binary(quotation.encoded_uri)
    end
  end

  describe "request/1" do
    test "request quote - missing parameters 422 response", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/quote", fn conn ->
        Plug.Conn.resp(conn, 422, @unauth)
      end)

      quote_request =
        Quote.new(%{
          to: ["Dagun", 4570],
          from: ["Cabramatta Weest", 2166],
          weight: 2,
          size: 0.01
        })

      assert %RequestError{
               code: "unprocessable_entity",
               message: desc,
               body: body,
               status: 422
             } = Sendle.Requests.Quote.request(quote_request)

      assert is_map(body)

      assert desc ==
               "The data you supplied is invalid. Error messages are in the messages section. Please fix those fields and try again."
    end
  end

  test "should not make request without proper formatting" do
    assert %RequestError{message: "missing url parameters", code: "missing_url_params"} =
             Quote.new(from: [], to: [])
  end

  test "request quote 200 response", %{bypass: bypass} do
    Bypass.expect(bypass, "GET", "/api/quote", fn conn ->
      Plug.Conn.resp(conn, 200, @valid)
    end)

    quotation =
      Quote.new(%{
        to: ["Dagun", 4570],
        from: ["Cabramatta West", 2166],
        weight: 2,
        size: 0.01
      })

    assert %Response{} = Quote.request(quotation)
  end
end
