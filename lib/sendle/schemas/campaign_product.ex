defmodule Sendle.Schemas.CampaignProduct do
  @moduledoc """
    Tied to a database table that will store - products being shipped to an Influencer.
  """
  use Ecto.Schema

  alias Sendle.Schemas.CampaignRollout

  @type t :: %__MODULE__{}

  schema "campaign_products" do
    belongs_to(:campaign_rollout, CampaignRollout)
    field(:campaign_product_id, :integer)
    field(:product_name, :string)
    field(:description, :string)
    field(:sku, :string)
  end
end
