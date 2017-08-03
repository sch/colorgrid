defmodule Colorgrid do
  @moduledoc """
  Documentation for Colorgrid.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Colorgrid.Router, [], [
        dispatch: dispatch()
      ])
    ]

    opts = [strategy: :one_for_one, name: Colorgrid.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_, [
        # route the /ws endpoint to our cowboy websocket handler
        {"/ws", Colorgrid.SocketHandler, []},
        # ... but then send everything else to plug
        {:_, Plug.Adapters.Cowboy.Handler, {Colorgrid.Router, []}}
      ]}
    ]
  end
end
