defmodule SendleWeb.Api do
  @moduledoc """
  This module surfaces an HTTP interface into the application.
    # Decided not to use Phoenix. Too bulky for a simple POC with 3 endpoints.
    # No HTML is rendering will be needed.
  """
  use Plug.Router
  import Plug.Conn

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Plug.Parsers.JSON],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(Plug.Static.IndexHtml, at: "/")
  plug(
    Plug.Static,
    at: "/",
    from: "./priv/front-end/build/",
    only: ~w(index.html favicon.ico static service-worker.js)
  )

  plug(:dispatch)
  plug(:match)

  alias Sendle.Campaigns
  alias Sendle.Campaigns.Campaign

  get "/ping" do
    data = Poison.encode!(%{data: "valid"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, data)
  end

  post "/sendle/campaigns" do
    with {:ok, %Campaign{}} <- Campaigns.create(conn.params) do
      json_response(conn, 201, %{data: %{status: :accepted}})
    else
      _ ->
        json_response(conn, 401, %{data: %{error: "Could not process the payload."}})
    end
  end

  get "/sendle/campaigns/:campaign_id" do
    %{"campaign_id" => campaign_id} = conn.params

    with camp_id when is_integer(camp_id) <- to_integer(campaign_id),
         %Campaign{} = campaign <- Campaigns.get_campaign(campaign_id: camp_id) do
      json_response(conn, 200, %{data: campaign})
    else
      _ -> json_response(conn, 404, %{data: %{error: "Campaign not found."}})
    end
  end

  put "/sendle/campaigns/:campaign_id/process" do
    with camp_id when is_integer(camp_id) <- to_integer(campaign_id),
         %Campaign{} = campaign <- Campaigns.get_campaign(campaign_id: camp_id),
         {:ok, order_requests} <- Campaigns.process_orders(campaign, conn.body_params),
         {:ok, request_responses} <- Campaigns.send_requests(order_requests),
         Campaigns.mark_as_processed(campaign_id),
         campaign = Campaigns.build_response(campaign, request_responses) do
      json_response(conn, 201, %{data: campaign})
    else
      {:error, :could_not_process_orders} ->
        json_response(conn, 422, %{data: %{error: "Not able to process sendle order"}})

      {:error, _responses} ->
        json_response(conn, 400, %{data: %{error: "Bad Request"}})
    end
  end

  get "/sendle/campaigns/:campaign_id/influencers/:influencer_id" do
    %{"campaign_id" => campaign_id, "influencer_id" => influencer_id} = conn.params

    case Campaigns.get_influencer_details(campaign_id, influencer_id) do
      :not_found -> json_response(conn, 404, %{data: %{error: "Not found"}})
      val -> json_response(conn, 200, %{data: val})
    end
  end

  get "/sendle/campaigns/:campaign_id/influencers/:influencer_id/current_order" do
    %{"campaign_id" => campaign_id, "influencer_id" => influencer_id} = conn.params

    with %{sendle_response: sendle_data} <-
           Campaigns.get_influencer_details(campaign_id, influencer_id),
         %{body: body, status: 200} = response <- Campaigns.get_labels(sendle_data) do
      json_response(conn, 200, %{data: body})
    else
      :not_found ->
        json_response(conn, 404, %{data: %{error: "Campaign / influencer mismatch. Resource not found"}})
      response ->
        json_response(conn, 404, %{data: response.body})
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
