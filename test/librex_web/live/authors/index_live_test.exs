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
      |> assert_has("h2", count: 12)
      |> fill_in("Search", with: "THISONE")
      |> submit()
      |> assert_has("h2", count: 2)
    end
  end

  describe "sort events" do
    test "sorts by name and recently added authors", %{conn: conn} do
      generate(author(name: "Alpha"))
      generate(author(name: "Gamma"))
      generate(author(name: "Beta"))

      conn
      |> visit(~p"/")
      |> select("sort by:", option: "name")
      |> assert_has("#authors-list>li:nth-child(1)", text: "Alpha")
      |> assert_has("#authors-list>li:nth-child(2)", text: "Beta")
      |> assert_has("#authors-list>li:nth-child(3)", text: "Gamma")
      |> select("sort by:", option: "recently added")
      |> assert_has("#authors-list>li:nth-child(1)", text: "Beta")
      |> assert_has("#authors-list>li:nth-child(2)", text: "Gamma")
      |> assert_has("#authors-list>li:nth-child(3)", text: "Alpha")
    end

    test "sorts by count of books", %{conn: conn} do
      a1 = generate(author(name: "Shakespear"))
      a2 = generate(author(name: "Homer"))
      a3 = generate(author(name: "Mary Shelley"))
      generate_many(book(author_id: a1.id), 10)
      generate_many(book(author_id: a2.id), 2)
      generate_many(book(author_id: a3.id), 1)

      conn
      |> visit(~p"/")
      |> select("sort by:", option: "number of books")
      |> assert_has("#authors-list>li:nth-child(1)", text: "Shakespear")
      |> assert_has("#authors-list>li:nth-child(2)", text: "Homer")
      |> assert_has("#authors-list>li:nth-child(3)", text: "Mary Shelley")
    end
  end

  describe "pagination" do
    test "filters the list of authors", %{conn: conn} do
      generate_many(author(prefix_name: "Alpha"), 12)
      generate_many(author(prefix_name: "Beta"), 12)
      generate_many(author(prefix_name: "Gamma"), 12)

      conn
      # Page 1/3
      |> visit(~p"/")
      |> select("sort by:", option: "name")
      |> assert_has("h2", text: "Alpha", count: 12)
      |> refute_has("h2", text: "Beta")
      |> refute_has("h2", text: "Gamma")
      |> assert_has("a[disabled]", text: "Previous")
      |> click_link("Next")
      # Page 2/3
      |> assert_has("h2", text: "Beta", count: 12)
      |> refute_has("h2", text: "Alpha")
      |> refute_has("h2", text: "Gamma")
      |> refute_has("a[disabled]", text: "Previous")
      |> click_link("Next")
      # Page 3/3
      |> assert_has("h2", text: "Gamma", count: 12)
      |> refute_has("h2", text: "Alpha")
      |> refute_has("h2", text: "Beta")
      |> assert_has("a[disabled]", text: "Next")
      |> click_link("Previous")
      # back to Page 2/3
      |> assert_has("h2", text: "Beta", count: 12)
      |> click_link("Previous")
      # back to Page 1/3
      |> assert_has("h2", text: "Alpha", count: 12)
    end
  end
end
