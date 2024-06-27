defmodule ViralSpiral.Repo do
  use Ecto.Repo,
    otp_app: :viral_spiral,
    adapter: Ecto.Adapters.Postgres
end
