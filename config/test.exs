use Mix.Config

config :sendle,
  api_credentials: %{
    api_endpoint: "http://localhost:8383",
    sendle_auth_id: System.get_env("TEST_SENDLE_ID"),
    sendle_api_key: System.get_env("TEST_SENDLE_API_KEY")
  }

config :bypass,
  port: 8383
