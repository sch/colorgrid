defmodule Colorgrid.Router do
  use Plug.Builder

  plug Plug.Logger
  plug Plug.Static, at: "/", from: :colorgrid
  plug :not_found

  def not_found(conn, _) do
    send_resp(conn, 404, "not found")
  end
end
