defmodule LibrexWeb.Authors.ShowLiveTest do
  use LibrexWeb.ConnCase, async: true

  alias Librex.Library

  describe "render/1" do
    test "can view authors details", %{conn: conn} do
      author = generate(author())

      conn
      |> visit(~p"/authors/#{author.id}")
      |> assert_has("h1", text: author.name)
    end
  end

  describe "handle_event/3" do
    test "'destroy' can delete authors", %{conn: conn} do
      author = generate(author())

      conn
      |> visit(~p"/authors/#{author}")
      |> click_button("Delete Author")
      |> assert_has(flash(:info), text: "Author deleted successfully")

      assert {:error, _} = Library.get_author_by_id(author.id)
    end

    test "'destroy' can delete authors with books", %{conn: conn} do
      author = generate(author())
      generate_many(book(author_id: author.id), 10)

      conn
      |> visit(~p"/authors/#{author}")
      |> click_button("Delete Author")
      |> assert_has(flash(:info), text: "Author deleted successfully")

      assert {:error, _} = Library.get_author_by_id(author.id)
    end

    test "'destroy-book' can delete books", %{conn: conn} do
      author = generate(author())
      book = generate(book(author_id: author.id))

      conn
      |> visit(~p"/authors/#{author}")
      |> within("#book-#{book.id}", fn conn ->
        conn
        |> click_button("Delete Book")
      end)
      |> assert_has(flash(:info), text: "Book deleted successfully")

      assert {:error, _} = Library.get_book_by_id(book.id)
    end
  end
end
