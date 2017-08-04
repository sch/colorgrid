defmodule Colorgrid.SocketHandler do
  @behaviour :cowboy_websocket_handler

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @timeout 60 * 1000 # one minute

  def websocket_init(_type, req, _opts) do
    state = %{}
    {:ok, req, state, @timeout}
  end

  def websocket_handle({:text, message}, req, state) do
    IO.puts message
    response = handle_message String.split(message, ":")
    {:reply, {:text, response}, req, state}
    # {:ok, req, state}
  end

  def websocket_info(message, req, state) do
    {:reply, {:text, message}, req, state}
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end

  defp handle_message(["color", color]) do
    "last color: #{color}"
  end

  defp handle_message([message, data]) do
    "error: couldn't handle message #{message} with data #{data}"
  end
end
