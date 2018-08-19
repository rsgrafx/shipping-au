defmodule Sendle.Schemas.SendleResponse do
  use Ecto.Schema

  schema "sendle_responses" do
    belongs_to(:campaign_participant, Sendle.Schemas.CampaignParticipant)
    field(:order_uuid, :string)
    field(:order_pdf_url, :string)
  end
end
