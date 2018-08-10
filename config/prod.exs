use Mix.Config

config :sendle, api_credentials: %{
  api_endpoint: System.get_env("API_SANDBOX"),
  sendle_auth_id: System.get_env("SENDLE_ID"),
  sendle_api_key: System.get_env("SENDLE_API_KEY")
}
