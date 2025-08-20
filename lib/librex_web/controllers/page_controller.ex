defmodule LibrexWeb.PageController do
  use LibrexWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
