defmodule LibrexWeb.Books.FormLive do
  use LibrexWeb, :live_view

  alias Librex.Library

  def mount(%{"author_id" => author_id}, _session, socket) do
    author = Library.get_author_by_id!(author_id)
    form = Library.form_to_create_book(author_id)

    socket =
      socket
      |> assign(:form, to_form(form))
      |> assign(:author, author)
      |> assign(:page_title, "New Book")

    {:ok, socket}
  end

  def mount(%{"id" => book_id}, _session, socket) do
    book = Library.get_book_by_id!(book_id)
    author = Library.get_author_by_id!(book.author_id)
    form = Library.form_to_update_book(book)

    socket =
      socket
      |> assign(:form, to_form(form))
      |> assign(:author, author)
      |> assign(:page_title, "New Book")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <.header>
        <h1>{@page_title}</h1>
      </.header>

      <.simple_form
        :let={form}
        id="book_form"
        as={:form}
        for={@form}
        phx-change="validate"
        phx-submit="save"
      >
        <.input name="author_id" label="Author" value={@author.name} disabled />
        <div class="sm:flex gap-8 space-y-8 md:space-y-0">
          <div class="sm:w-3/4">
            <.input field={form[:title]} label="Title" />
          </div>

          <div class="sm:w-1/4">
            <.input field={form[:year_released]} label="Year Released" type="number" />
          </div>
        </div>
        <.input field={form[:cover_image_url]} label="Cover image URL" />
        <:actions>
          <.button type="primary">Save</.button>
        </:actions>
      </.simple_form>
    </Layouts.app>
    """
  end

  def handle_event("validate", %{"form" => form_data}, socket) do
    socket =
      socket
      |> update(:form, &AshPhoenix.Form.validate(&1, form_data))

    {:noreply, socket}
  end

  def handle_event("save", %{"form" => form_data}, socket) do
    socket =
      case AshPhoenix.Form.submit(socket.assigns.form, params: form_data) do
        {:ok, book} ->
          socket
          |> put_flash(:info, "Book saved successfully")
          |> push_navigate(to: ~p"/authors/#{book.author_id}")

        {:error, form} ->
          socket
          |> put_flash(:error, "Could not save book data")
          |> assign(:form, form)
      end

    {:noreply, socket}
  end
end
