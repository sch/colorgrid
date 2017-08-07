defmodule ColorgridWeb.UserSocket do
  use Phoenix.Socket

  transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000

  channel "broadcast", ColorgridWeb.ColorChannel

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
