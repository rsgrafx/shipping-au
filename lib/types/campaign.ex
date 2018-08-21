defmodule Sendle.Campaigns.Campaign do
  @moduledoc """
    This datastructure keeps track of participants and products being
    used in a campaign rollout.
  """

  alias Sendle.Campaigns.{Participant, Product}
  alias Sendle.Schemas.CampaignRollout

  @type participant :: Participant.t()
  @type product :: Product.t()

  @type t :: %__MODULE__{
          campaign_id: integer,
          campaign_name: binary(),
          instructions: binary(),
          sender: map(),
          status: any(),
          participants: [participant],
          products: [product],
          packing_slips: list()
        }

  defstruct campaign_name: nil,
            campaign_id: nil,
            sender: nil,
            status: nil,
            instructions: nil,
            participants: [],
            products: [],
            packing_slips: nil

  @spec new(data :: map() | CampaignRollout.t()) :: t
  def new(%CampaignRollout{} = data) do
    struct(__MODULE__,
      campaign_name: data.name,
      campaign_id: data.campaign_id,
      instructions: data.instructions,
      status: data.status,
      sender: warehouse(:au),
      participants: build_participants(data.participants),
      products: build_products(data.products)
    )
  end

  def new(data) do
    struct(__MODULE__,
      campaign_name: data.campaign_name,
      campaign_id: data.campaign_id,
      instructions: data.notes,
      sender: warehouse(:au),
      participants: build_participants(data.participants),
      products: build_products(data.products)
    )
  end

  defp build_participants(list_of_participants) do
    Enum.map(list_of_participants, &Participant.build/1)
  end

  defp build_products(list_of_products) do
    Enum.map(list_of_products, &Product.build/1)
  end

  defp warehouse(sender_key, instructions \\ "") do
    vamp_address_locations = %{
      au: %{
        contact: %{name: "Admin", phone: "61 1300 606 614", company: "Vamp.me"},
        address: %{
          address_line1: "50 King Street",
          city: "Sydney",
          state_name: "NSW",
          postcode: "2000",
          country: "Australia"
        },
        instructions: instructions
      }
    }

    Map.get(vamp_address_locations, sender_key)
  end
end
