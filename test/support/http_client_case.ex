defmodule Sendle.HTTPClientCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # use ExVCR.Mock

      alias Sendle.HTTP.Client
      alias Sendle.HTTP.Response
      alias Sendle.HTTP.RequestError
    end
  end

  setup do
    port = Application.get_env(:bypass, :port)
    bypass = Bypass.open(port: port)
    {:ok, bypass: bypass}
    # ExVCR.Config.cassette_library_dir("fixture/api_stubs")
  end
end
