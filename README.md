# Vamp Sendle Integration


This this library will either be integrated as a standalone library in a (umbrella application) or may be run as a service.

Visit [Wiki](https://github.com/visual-amplifiers/sendle/wiki/A.-Vamp-Sendle-Service) for full description of service [here](https://github.com/visual-amplifiers/sendle/wiki/A.-Vamp-Sendle-Service).

#### Installation.

```elixir
def deps do
  [
    {:sendle, "~> 0.1.0"}
  ]
end
```

#### Development

Sign up for a test account with Sendle [here](https://sandbox.sendle.com/dashboard).

* Make sure you enable a test credit card account.

Review documenation for sendle here [API Docs](http://api-doc.sendle.com)

Environment variables needed.

```elixir

config :sendle,
  api_credentials: %{
    api_endpoint: System.get_env("TEST_API_SANDBOX"),
    sendle_auth_id: System.get_env("TEST_SENDLE_ID"),
    sendle_api_key: System.get_env("TEST_SENDLE_API_KEY")
  }

```


#### Production

This application is currently deployed to Heroku. See standard deployment instructions for elixir applications.  

* Requires PostgreSQL add on.
* Requires https://github.com/HashNuke/heroku-buildpack-elixir
* Does not require Phoenix static buildpack.


```elixir
config :sendle,
  api_credentials: %{
    api_endpoint: System.get_env("API_SANDBOX"),
    sendle_auth_id: System.get_env("SENDLE_ID"),
    sendle_api_key: System.get_env("SENDLE_API_KEY")
  }

```

Currently deployed to [sendle-api.herokuapp.com](http://sendle-api.herokuapp.com) this service 
maintains several endpoints in order to find or create shipping orders with the sendle api.

Currently only the [Sendle](www.Sendle.com) is used a shipping provider.
 

