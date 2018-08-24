defmodule SendleWeb.Api do
  @moduledoc """
  This module surfaces an HTTP interface into the application.
    # Decided not to use Phoenix. Too bulky for a simple POC with 3 endpoints.
    # No HTML is rendering will be needed.
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

  put "/sendle/campaigns/:campaign_id/process" do
    with camp_id when is_integer(camp_id) <- to_integer(campaign_id),
         %Campaign{} = campaign <- Sendle.Campaigns.get_campaign(campaign_id: camp_id),
         {:ok, order_requests} <- Sendle.Campaigns.process_orders(campaign, conn.body_params),
         {:ok, request_responses} <- Sendle.Campaigns.send_requests(order_requests) do
      json_response(conn, 201, %{data: campaign})
    else
      {:error, :could_not_process_orders} ->
        json_response(conn, 422, %{data: %{error: "Not able to process sendle order"}})

      {:error, _responses} ->
        json_response(conn, 400, %{data: %{error: "Bad Request"}})
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
