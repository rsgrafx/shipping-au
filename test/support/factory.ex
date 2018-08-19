defmodule Sendle.JSONFactory do
  use ExMachina

  alias Sendle.Campaigns.{
    Address,
    Participant
    # Product
  }

  def address_factory do
    %Address{
      city: "North Sydney",
      postcode: "2060",
      country: "Australia",
      state_name: "NSW",
      address_line1: "Level 1",
      address_line2: "17 Jones St"
    }
  end

  def participant_factory do
    %Participant{
      email: "",
      address: build(:address),
      full_name: "Ms. Jane Doe",
      note_for_shipper: "",
      quantity: nil,
      shipping_size: nil,
      shipping_weight: nil
    }
  end

  def sender_factory do
    %{
      name: "Admin",
      phone: "61 1300 606 614",
      company: "Vamp.me"
    }
  end

  def sender_address_factory do
    %{
      address_line1: "50 King Street",
      city: "Sydney",
      state_name: "NSW",
      postcode: "2000",
      country: "Australia"
    }
  end
end
