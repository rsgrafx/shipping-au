defmodule Sendle.Campaigns.Participant do
  @moduledoc """
    This data structure maintains specific information regarding
    participating influencer in a campaign.
  """

  alias Sendle.Campaigns.Address

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
