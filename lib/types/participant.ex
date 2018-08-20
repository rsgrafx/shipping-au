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
          quantity: integer()
        }

  defstruct full_name: nil,
            email: nil,
            address: nil,
            note_for_shipper: nil,
            shipping_size: nil,
            shipping_weight: nil,
            quantity: nil

  @spec build(data :: CampaignParticipant.t() | map()) :: t()
  @doc "Loading from from the database."
  def build(%CampaignParticipant{} = data) do
    values =
      Map.take(data, [:city, :postcode, :country, :state_name, :address_line1, :address_line2])

    struct(__MODULE__,
      address: build_address(values),
      full_name: data.full_name,
      email: data.email,
      note_for_shipper: data.note,
      shipping_size: data.size,
      weight: data.weight,
      quantity: data.quantity,
      shipping_instructions: data.note
    )
  end

  @doc "Building from the API."
  def build(data) do
    address = data.address

    data =
      struct(__MODULE__,
        full_name: address.full_name,
        email: address[:email] || "",
        address: build_address(address),
        note_for_shipper: address[:note] || "",
        shipping_size: nil,
        shipping_weight: nil,
        quantity: nil
      )
  end

  defp build_address(addr) do
    Address.build(addr)
  end
end