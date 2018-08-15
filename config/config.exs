# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :sendle,
  api_credentials: %{
    api_endpoint: System.get_env("TEST_API_SANDBOX"),
    sendle_auth_id: System.get_env("TEST_SENDLE_ID"),
    sendle_api_key: System.get_env("TEST_SENDLE_API_KEY")
  }

import_config "#{Mix.env()}.exs"
