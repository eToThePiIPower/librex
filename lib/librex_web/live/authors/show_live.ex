defmodule LibrexWeb.Authors.ShowLive do
  use LibrexWeb, :live_view
  require Logger

  alias Librex.Library

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => author_id}, _url, socket) do
    author = Library.get_author_by_id!(author_id, load: [:books])

    socket =
      socket
      |> assign(:page_title, author.name)
      |> assign(:author, author)

    {:noreply, socket}
  end

  def handle_event("destroy-author", _params, socket) do
    socket =
      case Library.destroy_author(socket.assigns.author) do
        :ok ->
          socket
          |> put_flash(:info, "Author deleted successfully")
          |> push_navigate(to: ~p"/")

        {:error, error} ->
          Logger.info("Could not delete author '#{socket.assigns.author.id}: #{inspect(error)}")

          socket
          |> put_flash(:error, "Could not delete author")
      end

    {:noreply, socket}
  end

  def handle_event("destroy-book", %{"book_id" => book_id}, socket) do
    socket =
      case Library.destroy_book(book_id) do
        :ok ->
          socket
          |> update(:author, fn author ->
            Map.update!(author, :books, fn books ->
              Enum.reject(books, &(&1.id == book_id))
            end)
          end)
          |> put_flash(:info, "Book deleted successfully")

        {:error, error} ->
          Logger.info("Could not delete book '#{socket.assigns.author.id}: #{inspect(error)}")

          socket
          |> put_flash(:error, "Could not delete book")
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <.header>
        <.h1>
          {@author.name}
        </.h1>
        <:actions>
          <.button
            class="btn btn-xs sm:btn-md btn-primary"
            navigate={~p"/authors/#{@author}/books/new"}
          >
            <.icon name="hero-plus" /> Add a Book
          </.button>
          <.button
            class="btn btn-xs sm:btn-md btn-soft"
            variant="primary"
            navigate={~p"/authors/#{@author}/edit"}
          >
            <.icon name="hero-plus" /> Edit Author
          </.button>
          <.button
            class="btn btn-xs sm:btn-md btn-error btn-soft"
            variant="danger"
            phx-click="destroy-author"
            data-confirm={"Are you sure you want to delete #{@author.name}?"}
          >
            Delete Author
          </.button>
        </:actions>
      </.header>

      <div class="mb-6">{@author.biography}</div>

      <div class="carousel carousel-center w-full p-4 space-x-4 rounded-box">
        <div :for={book <- @author.books} class="carousel-item">
          <.book_card book={book} />
        </div>
      </div>
    </Layouts.app>
    """
  end

  def book_card(assigns) do
    ~H"""
    <div id={"book-#{@book.id}"} class="card card-compact w-48 bg-base-100 shadow-xl">
      <figure><img src="https://placehold.co/400x400" alt="Shoes" /></figure>
      <div class="card-body">
        <h2 class="card-title">{@book.title}</h2>
        <p>{@book.year_released}</p>
      </div>
      <div class="card-actions">
        <.button navigate={~p"/books/#{@book}/edit"} class="btn btn-sm btn-block">Edit</.button>
        <.button
          class="btn btn-sm btn-error btn-soft btn-block"
          variant="danger"
          phx-click="destroy-book"
          phx-value-book_id={@book.id}
          data-confirm={"Are you sure you want to delete #{@book.title}?"}
        >
          Delete Book
        </.button>
      </div>
    </div>
    """
  end
end
