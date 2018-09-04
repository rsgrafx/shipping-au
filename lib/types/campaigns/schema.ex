defmodule Sendle.Schema do

  defmacro __using__(_opts) do
    quote do

      import Ecto.Query

      alias Sendle.Campaigns.Campaign

      alias Sendle.Schemas.{
        CampaignRollout,
        CampaignProduct,
        CampaignParticipant,
        ProductParticipant,
        SendleResponse
      }

      alias Sendle.Repo

      def atomize(%{"data" => _} = data, encoder) do
        data
        |> encoder.encode!()
        |> encoder.decode(keys: :atoms)
      end

      def atomize(%{data: _} = data, _) do
        data
      end

    end
  end
end
