defmodule ColorgridWeb.SocketHelpers do
  @moduledoc """
  view and URL helpers for socket endpoints
  """

  def socket_url(_conn) do
    ColorgridWeb.Endpoint.url
    |> URI.parse
    |> Map.update!(:scheme, fn scheme -> if (scheme == "https"), do: "wss", else: "ws" end)
    |> Map.put(:path, "/socket/websocket")
    |> URI.to_string
  end
end
