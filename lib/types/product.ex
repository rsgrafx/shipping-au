defmodule Sendle.Campaigns.Product do
  @moduledoc """
  This data structure maintains information regarding
  a product being used in a campaign.

  "campaign_product_id": 100,
  "name": "Metal Vent Tech Short Sleeve",
  "color": ["Pacific Breeze / Black"],
  "sku": "2034334"
  """

  @type t :: %__MODULE__{
          campaign_product_id: integer(),
          name: binary(),
          colors: [binary()],
          sku: binary()
        }

  defstruct name: nil, colors: [], sku: nil, campaign_product_id: nil

  def build(data) do
    struct(__MODULE__,
      name: data.name,
      colors: data.colors,
      sku: data.sku,
      campaign_product_id: data.campaign_product_id
    )
  end
end
