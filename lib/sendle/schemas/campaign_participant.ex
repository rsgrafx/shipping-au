defmodule Sendle.Schemas.CampaignParticipant do
  use Ecto.Schema

  schema "campaign_participants" do
    belongs_to(:campaign_rollout, Sendle.Schema.CampaignRollout)
    field(:campaign_id, :integer)
    field(:influencer_id, :integer)
    field(:full_name, :string, default: false)
    field(:email, :string, default: false)
    field(:address_line1, :string, default: false)
    field(:address_line2, :string, default: false)
    field(:city, :string, default: false)
    field(:state_name, :string)
    field(:country, :string, default: false)
    field(:postcode, :string, default: false)
    field(:note, :string)
    field(:size, :float)
    field(:weight, :float)
    field(:quantity, :integer)
    field(:shipping_instructions, :string)
  end
end
