defmodule Sendle.Schemas.SendleResponse do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sendle_responses" do
    belongs_to(:campaign_participant, Sendle.Schemas.CampaignParticipant)
    field(:order_id, :string)
    field(:order_pdf_url, :string)
    field(:price, :map)
    field(:route, :map)
    field(:sendle_reference, :string)
    field(:tracking_url, :string)
    field(:order_url, :string)
    field(:state, :string)
    field(:scheduling, :map)
  end

  @allowed ~w(order_id price route sendle_reference tracking_url order_url state scheduling)a
  def changeset(struct, params) do
    struct
    |> cast(params, @allowed)
    |> validate_required(@allowed)
  end
end
