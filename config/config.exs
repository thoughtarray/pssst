use Mix.Config

config :pssst, PssstWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nbYrKWrqCdULlnc6hl+nelnpsQQXFHxeAr12wdgL59inl8tG3XQgaO2OUp84u3Pi",
  render_errors: [view: PssstWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Pssst.PubSub,
  live_view: [signing_salt: "s8LcNyxw"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
