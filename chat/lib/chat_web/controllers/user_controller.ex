defmodule ChatWeb.UserController do
  use ChatWeb, :controller

  def show(conn, %{"user" => messenger}) do
    render(conn, "show.html", messenger: messenger)
  end

end
