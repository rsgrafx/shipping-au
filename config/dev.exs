use Mix.Config

config :sendle, Sendle.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "sendle_service_dev",
  username: "postgres",
  hostname: "localhost"

config :sendle, http_port: 8000
