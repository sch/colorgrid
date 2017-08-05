defmodule ColorgridWeb.ColorChannel do
  use Phoenix.Channel

  def join("broadcast", _message, socket) do
    {:ok, socket}
  end

  def handle_in("color:new", color_message, socket) do
    broadcast! socket, "color", color_message
    {:noreply, socket}
  end

  def handle_out("color:new", payload, socket) do
    push socket, "color:switch", payload
    {:noreply, socket}
  end
end
