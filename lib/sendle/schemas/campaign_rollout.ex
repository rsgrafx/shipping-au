defmodule Sendle.Schemas.CampaignRollout do
  use Ecto.Schema

  schema "campaign_rollouts" do
    has_many(:campaign_participants, Sendle.Schemas.CampaignParticipant)
    field(:name, :string)
    field(:campaign_id, :integer)
    field(:instructions, :string)
    field(:meta, :map)
  end
end
