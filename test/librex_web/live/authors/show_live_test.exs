defmodule LibrexWeb.Authors.ShowLiveTest do
  use LibrexWeb.ConnCase, async: true

  describe "render/1" do
    test "can view authors details", %{conn: conn} do
      author = generate(author())

      conn
      |> visit(~p"/authors/#{author.id}")
      |> assert_has("h1", text: author.name)
    end
  end
end
