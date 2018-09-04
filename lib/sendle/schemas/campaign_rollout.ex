defmodule Sendle.Schemas.CampaignRollout do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "campaign_rollouts" do
    has_many(:participants, Sendle.Schemas.CampaignParticipant)
    has_many(:products, Sendle.Schemas.CampaignProduct)
    field(:name, :string)
    field(:status, :string, default: :new)
    field(:campaign_id, :integer)
    field(:instructions, :string)
    field(:meta, :map)
    timestamps()
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

  def status_changeset(struct, params) do
    struct
    |> cast(params, [:status])
    |> validate_inclusion(:status, ["new", "processed", "failure"])
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
