defmodule SendleWeb.Api do
  @moduledoc """

  """
  use Plug.Router
  import Plug.Conn

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Plug.Parsers.JSON],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(:dispatch)

  alias Sendle.Campaigns.Campaign

  get "/ping" do
    data = Poison.encode!(%{data: "valid"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, data)
  end

  post "/sendle/campaigns" do
    with %Campaign{} = _campaign <- Sendle.Campaigns.create(conn.params),
         response = Poison.encode!(%{data: %{status: :accepted}}) do
      json_response(conn, 200, response)
    else
      _ ->
        json_response(conn, 401, %{data: %{error: "Could not process the payload."}})
    end
  end

  get "/sendle/campaigns/:campaign_id" do
    %{"campaign_id" => campaign_id} = conn.params

    with camp_id when is_integer(camp_id) <- to_integer(campaign_id),
         %Campaign{} = campaign <- Sendle.Campaigns.get_campaign(campaign_id: camp_id) do
      json_response(conn, 200, %{data: campaign})
    else
      _ -> json_response(conn, 404, %{data: %{error: "Campaign not found."}})
    end
  end

  defp json_response(conn, status, response) do
    body = Poison.encode!(response)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, body)
  end

  defp to_integer(value) do
    try do
      String.to_integer(value)
    rescue
      ArgumentError ->
        {:error, :not_a_number}
    end
  end
end
