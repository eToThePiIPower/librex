defmodule LibrexWeb.Authors.FormLive do
  use LibrexWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    form = Librex.Library.form_to_create_author()

    socket =
      socket
      |> assign(:form, to_form(form))
      |> assign(:page_title, "New Author")

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <.header>
        <h1>{@page_title}</h1>
      </.header>

      <.simple_form
        :let={form}
        id="author_form"
        as={:form}
        for={@form}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={form[:name]} label="Name" />
        <.input field={form[:biography]} type="textarea" label="Biography" />
        <:actions>
          <.button type="primary">Save</.button>
        </:actions>
      </.simple_form>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"form" => form_data}, socket) do
    socket =
      socket
      |> update(:form, &AshPhoenix.Form.validate(&1, form_data))

    {:noreply, socket}
  end

  def handle_event("save", %{"form" => form_data}, socket) do
    socket =
      case AshPhoenix.Form.submit(socket.assigns.form, params: form_data) do
        {:ok, author} ->
          socket
          |> put_flash(:info, "Author saved successfully")
          |> push_navigate(to: ~p"/authors/#{author}")

        {:error, form} ->
          socket
          |> put_flash(:error, "Could not save author data")
          |> assign(:form, form)
      end

    {:noreply, socket}
  end
end
