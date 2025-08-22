defmodule LibrexWeb.Authors.IndexLiveTest do
  use LibrexWeb.ConnCase, async: true

  describe "render/1" do
    test "can view authors list", %{conn: conn} do
      _authors = generate_many(author(), 10)

      conn
      |> visit(~p"/")
      |> assert_has("h2", count: 10)
    end

    test "displays an message when there are no authors", %{conn: conn} do
      conn
      |> visit(~p"/")
      |> assert_has("p", text: "No author data to display!")
    end
  end

  describe "search events" do
    test "filters the list of authors", %{conn: conn} do
      generate(author(name: "THISONE"))
      generate_many(author(), 10)
      generate(author(name: "THISONE TOO"))

      conn
      |> visit(~p"/")
      |> fill_in("Search", with: "THISONE")
      |> submit()
      |> assert_has("h2", count: 2)
    end
  end
end
