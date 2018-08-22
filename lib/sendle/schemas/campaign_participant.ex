defmodule Sendle.Schemas.CampaignParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  alias Sendle.Schemas.{CampaignRollout, CampaignProduct}

  schema "campaign_participants" do
    belongs_to(:campaign_rollout, CampaignRollout)
    has_many(:products, CampaignProduct)
    field(:campaign_id, :integer)
    field(:influencer_id, :integer)
    field(:full_name, :string, default: false)
    field(:email, :string, default: false)
    field(:address_line1, :string, default: false)
    field(:address_line2, :string, default: false)
    field(:city, :string, default: false)
    field(:state_name, :string)
    field(:country, :string, default: false)
    field(:postcode, :string, default: false)
    field(:note, :string)
    field(:size, :float)
    field(:weight, :float)
    field(:quantity, :integer)
    field(:shipping_instructions, :string)
  end

  @spec changeset(
          struct :: t(),
          map()
        ) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, allowed())
    |> validate_required(required())
  end

  defp required() do
    allowed() --
      [
        :address_line2,
        :state_name,
        :note,
        :size,
        :weight,
        :quantity,
        :shipping_instructions
      ]
  end

  def build(params) do
    addr = params.address

    %__MODULE__{
      address_line1: addr.address_line1,
      address_line2: addr.address_line2,
      city: addr.city,
      country: addr.country,
      postcode: addr.postcode,
      state_name: addr.state_name,
      campaign_id: params.campaign_id,
      email: params.email,
      full_name: params.full_name,
      shipping_instructions: params.note_for_shipper
    }
  end

  defp allowed do
    __MODULE__.__schema__(:fields) -- [:id]
  end
end
