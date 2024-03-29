defmodule Sendle.Campaigns.Participant do
  @moduledoc """
    This data structure maintains specific information regarding
    participating influencer in a campaign.
  """

  alias Sendle.Campaigns.Address
  alias Sendle.Schemas.CampaignParticipant

  @type t :: %__MODULE__{
          full_name: binary(),
          email: binary(),
          address: Address.t(),
          note_for_shipper: binary(),
          shipping_size: float(),
          shipping_weight: float(),
          quantity: integer(),
          influencer_id: integer(),
          products: list(),
          sendle_response: map()
        }

  defstruct full_name: nil,
            influencer_id: nil,
            email: nil,
            address: nil,
            note_for_shipper: nil,
            shipping_size: nil,
            shipping_weight: nil,
            quantity: nil,
            products: [],
            sendle_response: nil

  @spec build(data :: CampaignParticipant.t() | map()) :: t()
  @doc "Loading from from the database."
  def build(%CampaignParticipant{} = data) do
    values =
      Map.take(data, [
        :city,
        :postcode,
        :country,
        :state_name,
        :address_line1,
        :address_line2,
        :sendle_responses
      ])

    struct(__MODULE__,
      address: build_address(values),
      influencer_id: data.influencer_id,
      full_name: data.full_name,
      email: data.email,
      note_for_shipper: data.note,
      shipping_size: data.size,
      weight: data.weight,
      quantity: data.quantity,
      shipping_instructions: data.note,
      products: build_products(data),
      sendle_response: response(values.sendle_responses)
    )
  end

  @attrs [
    :order_id,
    :order_url,
    :price,
    :route,
    :scheduling,
    :reference,
    :tracking_url
  ]
  defp response([sendle | _]), do: Map.take(sendle, @attrs)
  defp response(_), do: []

  # "Building from the API."
  def build(data) do
    address = data.address

    struct(__MODULE__,
      full_name: address.full_name,
      email: data.email,
      influencer_id: data.influencer_id,
      address: build_address(address),
      note_for_shipper: address[:note] || "",
      shipping_size: nil,
      shipping_weight: nil,
      quantity: nil,
      products: data.products
    )
  end

  defp build_address(addr) do
    Address.build(addr)
  end

  defp build_products(%{products: %Ecto.Association.NotLoaded{}}), do: []

  defp build_products(%{products: products} = data) do
    Enum.map(products, fn product ->
      %{
        id: product.id,
        sku: product.sku,
        campaign_product_id: product.campaign_product_id,
        quantity: data.quantity,
        size: data.size
      }
    end)
  end
end
