defmodule Sendle.SchemaFactory do
  use ExMachina.Ecto, repo: Sendle.Repo
  # Functions to generate - Schema factories.
  alias Sendle.Schemas.{
    CampaignRollout,
    CampaignParticipant,
    CampaignProduct,
    ProductParticipant
  }

  ### - Database specific factories

  def campaign_rollout_factory do
    campaign_id = sequence(:campaign_id, & &1) + :rand.uniform(9_000_000)

    %CampaignRollout{
      name: sequence(:name, &"Nike Rollout - #{&1}"),
      campaign_id: campaign_id,
      instructions: "Make sure this gets out by Tuesday",
      meta: %{"mail_type" => "DHL"},
      participants: build_list(3, :campaign_participant),
      products: [build(:campaign_product)]
    }
  end

  def campaign_participant_factory do
    address = Enum.random(["50", "44", "66", "58-68", "70", "90"]) <> " King Street"
    %CampaignParticipant{
      campaign_id: nil,
      influencer_id: :rand.uniform(1_000_100) + sequence(:influencer_id, fn n -> n end),
      full_name: Faker.Name.name(),
      email: Faker.Internet.email(),
      address_line1: address,
      address_line2: nil,
      city: "Sydney",
      state_name: "NSW",
      country: "Australia",
      postcode: "2000",
      note: nil,
      size: 2.3,
      weight: nil,
      quantity: 3,
      shipping_instructions: "Leave at Front desk",
      products: []
    }
  end

  def assigned_product_factory do
    rollout = insert(:campaign_rollout)

    %ProductParticipant{
      campaign_rollout_id: rollout.id,
      campaign_participant_id: insert(:campaign_participant, campaign_rollout: rollout).id,
      campaign_product_id: insert(:campaign_product).id
    }
  end

  def campaign_product_factory do
    %CampaignProduct{
      campaign_product_id: 100,
      sku: sequence("SKU-100"),
      product_name: "Addidas Retro Jacket"
    }
  end
end
