use Mix.Config

config :sendle,
  api_credentials: %{
    api_endpoint: "http://localhost:8383",
    sendle_auth_id: System.get_env("TEST_SENDLE_ID"),
    sendle_api_key: System.get_env("TEST_SENDLE_API_KEY")
  }

config :bypass,
  port: 8383

config :logger, level: :debug

config :sendle, Sendle.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "sendle_service_test",
  username: "postgres",
  hostname: "localhost"
