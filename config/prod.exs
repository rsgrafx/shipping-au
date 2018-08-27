use Mix.Config

config :sendle,
  api_credentials: %{
    api_endpoint: System.get_env("API_SANDBOX"),
    sendle_auth_id: System.get_env("SENDLE_ID"),
    sendle_api_key: System.get_env("SENDLE_API_KEY")
  }

port =
  case System.get_env("PORT") do
    port when is_binary(port) -> String.to_integer(port)
    # default port
    nil -> 80
  end

config :sendle, http_port: port

config :sendle, Sendle.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true
