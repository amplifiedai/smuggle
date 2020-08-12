# We're supporting Elixir 1.8, so still using:
use Mix.Config

if Mix.env() == :test do
  config :stream_data, max_runs: if(System.get_env("CI"), do: 1_000, else: 50)
end
