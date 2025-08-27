defmodule LibrexWeb.Books.FormLiveTest do
  use LibrexWeb.ConnCase, async: true

  alias Librex.Library

  describe "creating a new book" do
    test "succeeds when valid details are entered", %{conn: conn} do
      author = generate(author(name: "Homer"))

      conn
      |> create_and_log_in_user(:admin)
      |> visit(~p"/authors/#{author}/books/new")
      |> fill_in("Title", with: "Iliad")
      |> fill_in("Year Released", with: "-800")
      |> fill_in("Cover image URL", with: "/images/cover/iliad.jpg")
      |> click_button("Save")
      |> assert_has(flash(:info), text: "Book saved successfully")
    end

    test "shows validation errors", %{conn: conn} do
      author = generate(author(name: "Homer"))

      conn
      |> create_and_log_in_user(:admin)
      |> visit(~p"/authors/#{author}/books/new")
      |> fill_in("Title", with: "")
      |> fill_in("Year Released", with: "-2101")
      |> fill_in("Cover image URL", with: "invalid")
      |> assert_has(field_error("title"), text: "is required")
      |> assert_has(field_error("year_released"), text: "must be between 2100 BCE and next year")
      |> assert_has(field_error("cover_image_url"), text: "must end in .png or .jpg")
      |> assert_has(field_error("cover_image_url"),
        text: "must start with http[s]:// or /images/cover/"
      )
    end

    test "fails when invalid details are entered", %{conn: conn} do
      author = generate(author(name: "Homer"))

      conn
      |> create_and_log_in_user(:admin)
      |> visit(~p"/authors/#{author}/books/new")
      |> fill_in("Title", with: "")
      |> fill_in("Year Released", with: "-2101")
      |> click_button("Save")
      |> assert_has(flash(:error), text: "Could not save book data")
    end

    test "fails when book already exists", %{conn: conn} do
      author = generate(author(name: "Homer"))
      _book = generate(book(author_id: author.id, title: "Iliad", year_released: -800))

      conn
      |> create_and_log_in_user(:admin)
      |> visit(~p"/authors/#{author}/books/new")
      |> fill_in("Title", with: "Iliad")
      |> fill_in("Year Released", with: "-790")
      |> click_button("Save")
      |> assert_has(flash(:error), text: "Could not save book data")
      |> assert_has(field_error("title"), text: "already exists")
    end
  end

  describe "updating an existing book" do
    test "succeeds when valid details are entered", %{conn: conn} do
      author = generate(author(name: "Homer"))
      book = generate(book(author_id: author.id, title: "Iliad", year_released: -800))

      conn
      |> create_and_log_in_user(:admin)
      |> visit(~p"/books/#{book}/edit")
      |> fill_in("Title", with: "Odyssey")
      |> fill_in("Year Released", with: "-750")
      |> click_button("Save")
      |> assert_has(flash(:info), text: "Book saved successfully")

      updated_book = Library.get_book_by_id!(book.id)
      assert updated_book.title == "Odyssey"
      assert updated_book.year_released == -750
    end

    test "shows validation errors", %{conn: conn} do
      author = generate(author(name: "Homer"))
      book = generate(book(author_id: author.id, title: "Iliad", year_released: -800))

      conn
      |> create_and_log_in_user(:admin)
      |> visit(~p"/books/#{book}/edit")
      |> fill_in("Year Released", with: "2200")
      |> fill_in("Cover image URL", with: "http://no_extension")
      |> assert_has(field_error("year_released"), text: "must be between 2100 BCE and next year")
      |> assert_has(field_error("cover_image_url"), text: "must end in .png or .jpg")
      |> refute_has(field_error("cover_image_url"),
        text: "must start with http[s]:// or /images/cover/"
      )
    end
  end

  test "fails when invalid details are entered", %{conn: conn} do
    author = generate(author(name: "Homer"))
    book = generate(book(author_id: author.id, title: "Iliad", year_released: -800))

    conn
    |> create_and_log_in_user(:admin)
    |> visit(~p"/books/#{book}/edit")
    |> fill_in("Title", with: "Odyssey")
    |> fill_in("Year Released", with: "-2101")
    |> click_button("Save")
    |> assert_has(flash(:error), text: "Could not save book data")

    updated_book = Library.get_book_by_id!(book.id)
    assert updated_book.title == "Iliad"
    assert updated_book.year_released == -800
  end
end
