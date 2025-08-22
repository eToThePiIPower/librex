defmodule LibrexWeb.Authors.FormLiveTest do
  use LibrexWeb.ConnCase, async: true

  alias Librex.Library

  describe "creating a new author" do
    test "succeeds when valid details are entered", %{conn: conn} do
      conn
      |> visit(~p"/authors/new")
      |> fill_in("Name", with: "Homer")
      |> click_button("Save")
      |> assert_has(flash(:info), text: "Author saved successfully")
    end

    test "shows validation errors", %{conn: conn} do
      conn
      |> visit(~p"/authors/new")
      |> fill_in("Name", with: "Homer")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("name"), text: "is required")
    end

    test "fails when invalid details are entered", %{conn: conn} do
      conn
      |> visit(~p"/authors/new")
      |> fill_in("Name", with: "")
      |> click_button("Save")
      |> assert_has(flash(:error), text: "Could not save author data")
    end
  end

  describe "updating an existing author" do
    test "succeeds when valid details are entered", %{conn: conn} do
      author = generate(author(name: "Obiwan Kenobi"))

      conn
      |> visit(~p"/authors/#{author}/edit")
      |> fill_in("Name", with: "Ben")
      |> click_button("Save")
      |> assert_has(flash(:info), text: "Author saved successfully")

      {:ok, updated_author} = Library.get_author_by_id(author.id)
      assert updated_author.name == "Ben"
    end

    test "shows validation errors", %{conn: conn} do
      author = generate(author(name: "Obiwan Kenobi"))

      conn
      |> visit(~p"/authors/#{author}/edit")
      |> fill_in("Name", with: "Ben")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("name"), text: "is required")
    end

    test "fails when invalid details are entered", %{conn: conn} do
      author = generate(author(name: "Obiwan Kenobi"))

      conn
      |> visit(~p"/authors/#{author}/edit")
      |> fill_in("Name", with: "")
      |> click_button("Save")
      |> assert_has(flash(:error), text: "Could not save author data")

      {:ok, updated_author} = Library.get_author_by_id(author.id)
      assert updated_author.name == "Obiwan Kenobi"
    end
  end
end
