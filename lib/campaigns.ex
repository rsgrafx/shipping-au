defmodule Sendle.Campaigns.Rollout do
  @moduledoc """
  Houses logic to start campaigns, processing incoming requests to
    build picking_lists and packing slips
  """

  alias Sendle.Campaigns.Campaign

  @type campaign :: Campaign.t()

  @doc """
    Entrypoint for system.
  """
  def create(payload) when is_binary(payload) do
    with {:ok, payload} <- Poison.decode(payload, keys: :atoms) do
      create(payload)
    else
      _ -> {:error, :cannot_decode_payload, payload}
    end
  end

  @spec create(map()) :: campaign
  def create(%{data: data} = payload) when is_map(payload) do
    Campaign.new(data)
  end
end
