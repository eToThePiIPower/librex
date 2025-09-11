defmodule LibrexWeb.JsonApi.BookTest do
  use LibrexWeb.ConnCase, async: true

  import AshJsonApi.Test

  describe "GET /books" do
    test "anyone can read an author's books" do
      author = generate(author())
      generate(book(author_id: author.id, title: "First Book", year_released: 2001))
      generate(book(author_id: author.id, title: "Second Book", year_released: 2002))

      get(
        Librex.Library,
        "/authors/#{author.id}/books",
        router: LibrexWeb.AshJsonApiRouter,
        status: 200
      )
      |> assert_data_matches([
        %{"attributes" => %{"title" => "Second Book"}},
        %{"attributes" => %{"title" => "First Book"}}
      ])
    end
  end

  describe "POST /books" do
    test "admins can create a book" do
      user = generate(user(role: :admin))
      author = generate(author())

      post(
        Librex.Library,
        "/books",
        %{
          data: %{
            attributes: %{author_id: author.id, title: "A New Title", year_released: 1999}
          }
        },
        router: LibrexWeb.AshJsonApiRouter,
        status: 201,
        actor: user
      )
      |> assert_data_matches(%{
        "attributes" => %{"title" => "A New Title", "year_released" => 1999}
      })
    end
  end

  describe "PATCH /books" do
    test "admins can update a book" do
      user = generate(user(role: :admin))
      book = generate(book())

      patch(
        Librex.Library,
        "/books/#{book.id}",
        %{
          data: %{
            attributes: %{title: "An Updated Title"}
          }
        },
        router: LibrexWeb.AshJsonApiRouter,
        status: 200,
        actor: user
      )
      |> assert_data_matches(%{
        "attributes" => %{"title" => "An Updated Title"}
      })
    end
  end

  describe "DELETE /books" do
    test "admins can delete a book" do
      user = generate(user(role: :admin))
      book = generate(book(title: "Test"))

      delete(
        Librex.Library,
        "/books/#{book.id}",
        router: LibrexWeb.AshJsonApiRouter,
        status: 200,
        actor: user
      )
      |> assert_data_matches(%{
        "attributes" => %{"title" => "Test"}
      })
    end
  end
end
