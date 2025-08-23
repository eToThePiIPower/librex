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
    page_params = AshPhoenix.LiveView.page_from_params(params, 12)
    sort_by = Map.get(params, "sort_by") |> validate_sortby()
    page = Library.search_authors!(query_text, page: page_params, query: [sort_input: sort_by])

    socket =
      socket
      |> assign(:page, page)
      |> assign(:sort_by, sort_by)
      |> assign(:query_text, query_text)

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"query" => query_text}, socket) do
    params = remove_empty(%{q: query_text, sort_by: socket.assigns.sort_by})
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  def handle_event("change-sortby", %{"sort_by" => sort_by}, socket) do
    params = remove_empty(%{q: socket.assigns.query_text, sort_by: sort_by})
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
          <.select_sortby selected={@sort_by} />
          <.button variant="primary" navigate={~p"/authors/new"}>
            <.icon name="hero-plus" /> New Author
          </.button>
        </:actions>
      </.header>

      <div :if={@page.results == []} class="p-8 text-center">
        <.icon name="hero-face-frown" class="w-32 h-32 bg-gray-300" />
        <p>No author data to display!</p>
      </div>

      <ul
        id="authors-list"
        class="gap-6 lg:gap-12 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4"
      >
        <li :for={author <- @page.results} id={author.id}>
          <.author_card author={author} />
        </li>
      </ul>

      <.pagination_links page={@page} query_text={@query_text} sort_by={@sort_by} />
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

  def search_box(assigns) do
    ~H"""
    <form class="relative w-fit inline-block" {@rest}>
      <.input
        container_class="!inline-block"
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

  def select_sortby(assigns) do
    assigns = assign(assigns, :options, sort_options())

    ~H"""
    <form data-role="author-sort" class="hidden sm:inline" phx-change="change-sortby">
      <.input
        label="sort by:"
        label_class="sr-only"
        type="select"
        id="sort_by"
        name="sort_by"
        options={@options}
        value={@selected}
        class="select"
        container_class="!inline-block"
      />
    </form>
    """
  end

  def pagination_links(assigns) do
    ~H"""
    <div
      :if={AshPhoenix.LiveView.prev_page?(@page) || AshPhoenix.LiveView.next_page?(@page)}
      class="flex justify-center pt-8 space-x-4"
    >
      <.button
        data-role="previous-page"
        variant="primary"
        patch={~p"/?#{query_string(@page, @query_text, @sort_by, "prev")}"}
        disabled={!AshPhoenix.LiveView.prev_page?(@page)}
      >
        « Previous
      </.button>
      <.button
        data-role="previous-page"
        variant="primary"
        patch={~p"/?#{query_string(@page, @query_text, @sort_by, "next")}"}
        disabled={!AshPhoenix.LiveView.next_page?(@page)}
      >
        Next »
      </.button>
    </div>
    """
  end

  defp query_string(page, query_text, sort_by, which) do
    case AshPhoenix.LiveView.page_link_params(page, which) do
      :invalid -> []
      list -> list
    end
    |> Keyword.put(:q, query_text)
    |> Keyword.put(:sort_by, sort_by)
    |> remove_empty()
  end

  defp validate_sortby(key) do
    valid_keys = Enum.map(sort_options(), &elem(&1, 1))

    if key in valid_keys do
      key
    else
      List.first(valid_keys)
    end
  end

  defp sort_options(),
    do: [
      {"name", "name"},
      {"recently updated", "-updated_at"},
      {"recently added", "-inserted_at"}
    ]

  defp remove_empty(params) do
    Enum.filter(params, fn {_key, value} -> value != nil && value != "" end)
  end
end
