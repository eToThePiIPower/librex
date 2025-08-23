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
  def handle_params(params, _url, socket) do
    query_text = Map.get(params, "q", "")
    authors = Library.search_authors!(query_text)

    socket =
      socket
      |> assign(:authors, authors)
      |> assign(:query_text, query_text)

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"query" => query_text}, socket) do
    params = remove_empty(%{q: query_text})
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        <.h1>Authors</.h1>
        <:actions>
          <.search_box query={@query_text} data-role="artist-search" phx-submit="search" />
          <.button variant="primary" navigate={~p"/authors/new"}>
            <.icon name="hero-plus" /> New Author
          </.button>
        </:actions>
      </.header>

      <div :if={@authors == []} class="p-8 text-center">
        <.icon name="hero-face-frown" class="w-32 h-32 bg-gray-300" />
        <p>No author data to display!</p>
      </div>

      <ul
        id="authors-list"
        class="gap-6 lg:gap-12 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4"
      >
        <li :for={author <- @authors} id={author.id}>
          <.author_card author={author} />
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

  attr :query, :string, default: ""
  attr :rest, :global

  @spec search_box(map()) :: Phoenix.LiveView.Rendered.t()
  def search_box(assigns) do
    ~H"""
    <form class="relative w-fit inline-block" {@rest}>
      <.input
        fieldset?={false}
        label="Search"
        icon="hero-magnifying-glass"
        name="query"
        id="search-text"
        value={@query}
        accesskey="s"
      />
    </form>
    """
  end

  defp remove_empty(params) do
    Enum.filter(params, fn {_key, value} -> value != "" end)
  end
end
