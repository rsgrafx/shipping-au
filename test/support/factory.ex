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

  # 118-132 Enmore Rd, Newtown NSW 2042, Australia
  def create_order_factory do
    %{
      cubic_metre_volume: "0.01",
      customer_reference: "Nothing to say.",
      description: "Vamp.me Order",
      influencer_id: :rand.uniform(100),
      kilogram_weight: "1",
      meta_data: %{},
      pickup_date: "2018-09-24",
      receiver: %{
        instructions: "notes supplied specifically for order",
        address: %{
          address_line1: "118-132 Enmore Rd",
          country: "Australia",
          postcode: 2042,
          state_name: "NSW",
          suburb: "Newtown"
        },
        contact: %{
          company: "",
          email: sequence(:email, &"foo#{&1}@email.com"),
          name: Faker.Name.name()
        }
      },
      sender: %{
        address: %{
          address_line1: "50 King Street",
          city: "Sydney",
          suburb: "Sydney",
          country: "Australia",
          postcode: "2000",
          state_name: "NSW"
        },
        contact: %{company: "Vamp.me", name: "Admin", phone: "61 1300 606 614"},
        instructions: "No instructions supplied by receiver"
      }
    }
  end
end
