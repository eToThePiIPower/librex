defmodule LibrexWeb.Books.FormLiveTest do
  use LibrexWeb.ConnCase, async: true

  describe "creating a new book" do
    test "succeeds when valid details are entered", %{conn: conn} do
      author = generate(author(name: "Homer"))

      conn
      |> visit(~p"/authors/#{author}/books/new")
      |> fill_in("Title", with: "Iliad")
      |> fill_in("Year Released", with: "-800")
      |> click_button("Save")
      |> assert_has(flash(:info), text: "Book saved successfully")
    end

    test "shows validation errors", %{conn: conn} do
      author = generate(author(name: "Homer"))

      conn
      |> visit(~p"/authors/#{author}/books/new")
      |> fill_in("Title", with: "")
      |> fill_in("Year Released", with: "-2101")
      |> assert_has(field_error("title"), text: "is required")
      |> assert_has(field_error("year_released"), text: "must be more than or equal to -2100")
    end

    test "fails when invalid details are entered", %{conn: conn} do
      author = generate(author(name: "Homer"))

      conn
      |> visit(~p"/authors/#{author}/books/new")
      |> fill_in("Title", with: "")
      |> fill_in("Year Released", with: "-2101")
      |> click_button("Save")
      |> assert_has(flash(:error), text: "Could not save book data")
    end
  end
end
