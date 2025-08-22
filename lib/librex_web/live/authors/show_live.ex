defmodule LibrexWeb.Authors.ShowLive do
  use LibrexWeb, :live_view
  require Logger

  alias Librex.Library

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => author_id}, _url, socket) do
    {:ok, author} = Library.get_author_by_id(author_id)

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

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <.header>
        <h1>
          {@author.name}
        </h1>
        <:actions>
          <.button variant="primary" navigate={~p"/authors/#{@author}/edit"}>
            <.icon name="hero-plus" /> Edit Author
          </.button>
          <.button
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
        <div class="carousel-item">
          <.book_card book={%{title: "Tolkienesque"}} />
        </div>
        <div class="carousel-item">
          <.book_card book={%{title: "Getting Better"}} />
        </div>
        <div class="carousel-item">
          <.book_card book={%{title: "Jackpot"}} />
        </div>
        <div class="carousel-item">
          <.book_card book={%{title: "Phoned it In"}} />
        </div>
        <div class="carousel-item">
          <.book_card book={%{title: "10 Years Late"}} />
        </div>
        <div class="carousel-item">
          <.book_card book={%{title: "A Slow Regard for the Fans"}} />
        </div>
        <div class="carousel-item">
          <.book_card book={%{title: "Just Let Brandon Finish It"}} />
        </div>
      </div>
    </Layouts.app>
    """
  end

  def book_card(assigns) do
    ~H"""
    <div class="card card-compact w-48 bg-base-100 shadow-xl">
      <figure><img src="https://placehold.co/400x400" alt="Shoes" /></figure>
      <div class="card-body">
        <h2 class="card-title">{@book.title}</h2>
      </div>
    </div>
    """
  end
end
