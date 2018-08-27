defmodule Sendle.HTTP.ClientTest do
  use Sendle.HTTPClientCase

  setup do
    Application.put_env(:sendle, :api_credentials, %{
      api_endpoint: "http://localhost:8383",
      sendle_auth_id: System.get_env("TEST_SENDLE_ID"),
      sendle_api_key: System.get_env("TEST_SENDLE_API_KEY")
    })
  end

  describe "PING Client.get/3" do
    test "/api/ping returns 200 Ok", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/ping", fn conn ->
        Plug.Conn.resp(conn, 200, ~s<{"ping":"pong","timestamp":"2018-04-05T15:52:48+10:00"}>)
      end)

      # use_cassette "ping" do
      request = Sendle.Requests.Ping.request()

      assert %Response{status: 200} = request
      # end
    end
  end

  @creds Sendle.get_api_credentials()

  describe "Client.post/3" do
    setup tags do
      %{params: Map.merge(tags.params, %{foo: :bar})}
    end

    @tag params: %{
           endpoint: "/api/ping",
           headers: [{"content-type", "application/json"}, {"accept", "application/json"}],
           auth: [basic_auth: {@creds.sendle_auth_id, @creds.sendle_api_key}]
         }
    test "GET delegates to HTTPoison get", %{params: params, bypass: bypass} do
      Bypass.expect(bypass, "GET", params.endpoint, fn conn ->
        Plug.Conn.resp(conn, 200, ~s<{"ping":"pong","timestamp":"2018-04-05T15:52:48+10:00"}>)
      end)

      assert %Response{status: 200, body: body} =
               Client.get(
                 params.endpoint,
                 params.headers,
                 params.auth
               )

      assert is_map(body)
    end

    @tag params: %{
           endpoint: "/api/ping",
           headers: [{"content-type", "application/json"}, {"accept", "application/json"}],
           auth: [basic_auth: {@creds.sendle_auth_id, @creds.sendle_api_key}]
         }
    test "GET delegates to HTTPoison get with Idompetency key returns cached result", %{
      params: params,
      bypass: bypass
    } do
      Bypass.expect(bypass, "GET", params.endpoint, fn conn ->
        Plug.Conn.resp(conn, 200, ~s<{"ping":"pong","timestamp":"2018-04-05T15:52:48+10:00"}>)
      end)

      uuid = UUID.uuid1()

      %Response{body: first_body} =
        Client.get(
          params.endpoint,
          params.headers ++ [{"indempotency-key", uuid}],
          params.auth
        )

      assert %{body: ^first_body} =
               Client.get(
                 params.endpoint,
                 params.headers ++ [{"indempotency-key", uuid}],
                 params.auth
               )
    end
  end

  @tag params: %{
         endpoint: "/api/ping",
         headers: [{"content-type", "application/json"}, {"accept", "application/json"}],
         auth: [basic_auth: {@creds.sendle_auth_id, @creds.sendle_api_key}]
       }
  test "returns `Sendle.Response`", %{params: params, bypass: bypass} do
    Bypass.expect(bypass, "GET", params.endpoint, fn conn ->
      Plug.Conn.resp(conn, 200, ~s<{"ping":"pong","timestamp":"2018-04-05T15:52:48+10:00"}>)
    end)

    assert %Response{body: response_body} =
             Client.get(
               params.endpoint,
               params.headers ++ [{"indempotency-key", UUID.uuid1()}],
               params.auth
             )

    assert is_map(response_body)
  end

  @tag params: %{
         endpoint: "/api/ping",
         headers: [{"content-type", "application/json"}, {"accept", "application/json"}],
         auth: [basic_auth: {@creds.sendle_auth_id, "FOOBAR"}]
       }
  test "response should be Sendle.HTTP.RequestError", %{params: params, bypass: bypass} do
    response =
      "The authorisation details are not valid. Either the Sendle ID or API key are incorrect."

    Bypass.expect(bypass, "GET", params.endpoint, fn conn ->
      Plug.Conn.resp(conn, 401, ~s<{"error":"unauthorized","error_description":"#{response}"}>)
    end)

    assert %RequestError{message: ^response, code: "unauthorized"} =
             Client.get(
               params.endpoint,
               params.headers,
               params.auth
             )
  end
end
