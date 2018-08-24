defmodule Sendle.Repo.Migrations.AddMissingSendleParams do
  use Ecto.Migration

  def change do
    rename table(:sendle_responses), :order_uuid, to: :order_id

    alter table(:sendle_responses) do
      add(:price, :map)
      add(:route, :map)
      add(:sendle_reference, :string)
      add(:tracking_url, :string)
    end
  end
end
