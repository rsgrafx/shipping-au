defmodule Sendle.Schemas.CampaignRollout do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "campaign_rollouts" do
    has_many(:participants, Sendle.Schemas.CampaignParticipant)
    has_many(:products, Sendle.Schemas.CampaignProduct)
    field(:name, :string)
    field(:status, :string, virtual: true, default: :new)
    field(:campaign_id, :integer)
    field(:instructions, :string)
    field(:meta, :map)
  end

  @allowed [:name, :campaign_id, :instructions, :meta]
  @spec changeset(
          struct :: t(),
          params :: map()
        ) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @allowed)
    |> validate_required(@allowed -- [:meta])
  end

  @spec build(campaign :: map()) :: t()
  def build(campaign) do
    %__MODULE__{
      name: campaign.campaign_name,
      campaign_id: campaign.campaign_id,
      instructions: campaign.instructions
    }
  end
end
