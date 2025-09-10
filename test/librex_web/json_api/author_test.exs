defmodule LibrexWeb.JsonApi.AuthorTest do
  use LibrexWeb.ConnCase, async: true

  import AshJsonApi.Test

  describe "GET /authors" do
    test "anyone can search authors" do
      generate(author(name: "one", book_count: 2))
      generate(author(name: "two"))
      generate(author(name: "three"))

      get(
        Librex.Library,
        "/authors?query=o&fields=name,book_count&sort=name",
        router: LibrexWeb.AshJsonApiRouter,
        status: 200
      )
      |> assert_data_matches([
        %{"attributes" => %{"name" => "one", "book_count" => 2}},
        %{"attributes" => %{"name" => "two", "book_count" => 0}}
      ])
    end

    test "anyone can read an author by ID" do
      author = generate(author(name: "Authentic Author"))

      get(
        Librex.Library,
        "/authors/#{author.id}",
        router: LibrexWeb.AshJsonApiRouter,
        status: 200
      )
      |> assert_data_matches(%{"attributes" => %{"name" => "Authentic Author"}})
    end
  end

  describe "POST /authors" do
    test "admin can create an author" do
      user = generate(user(role: :admin))

      post(
        Librex.Library,
        "/authors",
        %{
          data: %{
            attributes: %{name: "New Author from JSON API test"}
          }
        },
        router: LibrexWeb.AshJsonApiRouter,
        status: 201,
        actor: user
      )
      |> assert_data_matches(%{
        "attributes" => %{"name" => "New Author from JSON API test"}
      })
    end
  end

  describe "PATCH /authors" do
    test "admins can update an author" do
      user = generate(user(role: :admin))
      author = generate(author(name: "Authentic Author"))

      patch(
        Librex.Library,
        "/authors/#{author.id}",
        %{
          data: %{
            attributes: %{name: "Author formerly known as Authentic"}
          }
        },
        router: LibrexWeb.AshJsonApiRouter,
        status: 200,
        actor: user
      )
      |> assert_data_matches(%{
        "attributes" => %{"name" => "Author formerly known as Authentic"}
      })
    end
  end

  describe "DELETE /authors" do
    test "admins can delete an author" do
      user = generate(user(role: :admin))
      author = generate(author(name: "Authentic Author"))

      delete(
        Librex.Library,
        "/authors/#{author.id}",
        router: LibrexWeb.AshJsonApiRouter,
        status: 200,
        actor: user
      )
      |> assert_data_matches(%{
        "attributes" => %{"name" => "Authentic Author"}
      })
    end
  end
end
