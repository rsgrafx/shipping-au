ExUnit.start()
Faker.start()
Application.ensure_all_started(:ex_machina)
Application.ensure_all_started(:bypass)

ExUnit.configure(timeout: :infinity)
