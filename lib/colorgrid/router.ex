defmodule Colorgrid.Router do
  use Plug.Router

  plug Plug.Logger
  plug Plug.Static, at: "/", from: :colorgrid
  plug :match
  plug :dispatch

  get "/" do
    data = "priv/static/phone.html"
      |> Path.expand
      |> File.read!
    conn |> send_resp(200, data)
  end

  get "/control" do
    data = "priv/static/controller.html"
      |> Path.expand
      |> File.read!
    conn |> send_resp(200, data)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
