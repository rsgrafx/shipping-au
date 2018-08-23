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
    %CampaignRollout{
      name: sequence(:name, &"Nike Rollout - #{&1}"),
      campaign_id: :rand.uniform(50),
      instructions: "Make sure this gets out by Tuesday",
      meta: %{"mail_type" => "DHL"},
      participants: build_list(3, :campaign_participant),
      products: [build(:campaign_product)]
    }
  end

  def campaign_participant_factory do
    %CampaignParticipant{
      campaign_id: 12,
      influencer_id: :rand.uniform(1_000_100) + sequence(:influencer_id, fn n -> n end),
      full_name: Faker.Name.name(),
      email: Faker.Internet.email(),
      address_line1: "12 Foo Bar st",
      address_line2: "Lot 11",
      city: "Cabbage Tree",
      state_name: "VIC",
      country: "Australia",
      postcode: "3364",
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
