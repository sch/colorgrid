defmodule ColorgridWeb.SocketHelpers do
  @moduledoc """
  view and URL helpers for socket endpoints
  """

  def socket_url(socket) do
    ColorgridWeb.Endpoint.url
    |> URI.parse
    |> Map.update!(:scheme, &websocket_scheme/1)
    |> Map.put(:path, endpoint_for(socket) <> "/websocket")
    |> URI.to_string
  end

  defp websocket_scheme(scheme) do
    if (scheme == "https"), do: "wss", else: "ws"
  end

  defp endpoint_for(socket) do
    ColorgridWeb.Endpoint.__sockets__
    |> Enum.find(fn {_, sock} -> sock == socket end)
    |> elem(0)
  end
end
