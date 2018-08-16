defmodule Sendle.Repo.Migrations.AddShippingSendleResponses do
  use Ecto.Migration

  def change do
    create table(:sendle_responses) do
      add(:campaign_participant_id, references(:campaign_participants))
      add(:order_uuid, :string)
      add(:order_pdf_url, :string)
    end
  end
end
