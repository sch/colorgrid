defmodule ColorgridWeb.PageController do
  use ColorgridWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def control(conn, _params) do
    render conn, "controller.html"
  end
end
