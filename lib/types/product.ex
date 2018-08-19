defmodule Sendle.Campaigns.Product do
  @moduledoc """
  This data structure maintains information regarding
  a product being used in a campaign.

    "campaign_product_id": 100,
    "name": "Metal Vent Tech Short Sleeve",
    "color": ["Pacific Breeze / Black"],
    "sku": "2034334"
  """
  defstruct name: nil, colors: [], sku: nil, campaign_product_id: nil

  alias Sendle.Schemas.CampaignProduct

  @type t :: %__MODULE__{
          campaign_product_id: integer(),
          name: binary(),
          sku: binary()
        }

  @spec build(data :: CampaignProduct.t() | map()) :: t
  def build(%CampaignProduct{} = data) do
    struct(__MODULE__,
      name: data.product_name,
      sku: data.sku,
      campaign_product_id: data.campaign_product_id
    )
  end

  def build(data) do
    struct(__MODULE__,
      name: data.name,
      sku: data.sku,
      campaign_product_id: data.campaign_product_id
    )
  end
end
