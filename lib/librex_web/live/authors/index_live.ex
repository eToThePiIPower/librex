defmodule LibrexWeb.Authors.IndexLive do
  use LibrexWeb, :live_view

  alias Librex.Library

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Authors")

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    authors = Library.read_authors!()
    empty = Enum.empty?(authors)

    socket =
      socket
      |> stream(:authors, authors)
      |> assign(:authors_empty, empty)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        <h1>Authors</h1>
        <:actions>
          <.button variant="primary" navigate={~p"/authors/new"}>
            <.icon name="hero-plus" /> New Author
          </.button>
        </:actions>
      </.header>

      <div :if={@authors_empty} class="p-8 text-center">
        <.icon name="hero-face-frown" class="w-32 h-32 bg-gray-300" />
        <p>No author data to display!</p>
      </div>

      <ul
        id="authors-stream"
        phx-update="stream"
        class="gap-6 lg:gap-12 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4"
      >
        <li :for={{id, author} <- @streams.authors} id={id}>
          <.author_card id={id} author={author} />
        </li>
      </ul>
    </Layouts.app>
    """
  end

  def author_card(assigns) do
    ~H"""
    <div data-role="author-card" class="card bg-base-100 shadow-xl">
      <.link navigate={~p"/authors/#{@author.id}"}>
        <figure><img src="https://placehold.co/400x400" alt="Shoes" /></figure>
        <div class="card-body h-48">
          <h2 class="card-title">{@author.name}</h2>
          <p>{@author.biography}</p>
        </div>
      </.link>
    </div>
    """
  end
end
