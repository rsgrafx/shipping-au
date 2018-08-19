defmodule Sendle.Repo.Migrations.AddShippingCampaignsParticipantsTable do
  use Ecto.Migration

  def change do
    create table(:campaign_participants) do
      add(:campaign_id, :integer)
      add(:influencer_id, :integer)
      add(:full_name, :string, default: false)
      add(:email, :string, default: false)
      add(:address_line1, :string, default: false)
      add(:address_line2, :string, default: false)
      add(:city, :string, default: false)
      add(:state_name, :string)
      add(:country, :string, default: false)
      add(:postcode, :string, default: false)
      add(:note, :string)
      add(:size, :float)
      add(:weight, :float)
      add(:quantity, :integer)
      add(:shipping_instructions, :string)
    end
  end
end
