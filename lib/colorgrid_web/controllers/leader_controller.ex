defmodule ColorgridWeb.LeaderController do
  use ColorgridWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
