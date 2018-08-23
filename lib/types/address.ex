defmodule Sendle.Campaigns.Address do
  @moduledoc """
  Shipping address for an Influencer.
  """
  import Ecto.Changeset
  alias Sendle.DataBuilder

  @type t :: %__MODULE__{
          city: binary(),
          postcode: binary(),
          country: binary(),
          state_name: binary(),
          address_line1: binary(),
          address_line2: binary()
        }

  defstruct city: :string,
            postcode: :string,
            country: :string,
            state_name: :string,
            address_line1: :string,
            address_line2: :string

  # building from db record. # Which matches sendles address naming conventions
  def build(%{address_line1: _, address_line2: _, state_name: _} = address) do
    struct(__MODULE__,
      address_line1: address.address_line1,
      address_line2: address.address_line2,
      city: address.city,
      state_name: address.state_name,
      country: address.country,
      postcode: address.postcode
    )
  end

  def build(address) do
    struct(__MODULE__,
      address_line1: address.address_line_1,
      address_line2: address.address_line_2,
      city: address.city,
      state_name: address.state,
      country: address.country,
      postcode: address.postcode
    )
  end

  @params [:address_line1, :city, :state_name, :country, :postcode]
  def changeset(params) do
    struct(__MODULE__)
    |> DataBuilder.cast(params, @params)
    |> validate_required(@params)
  end
end
