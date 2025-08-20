defmodule LibrexWeb.NavbarComponents do
  use Phoenix.Component
  import LibrexWeb.CoreComponents, only: [icon: 1]
  import LibrexWeb.Layouts, only: [theme_toggle: 1]

  def navbar(assigns) do
    ~H"""
    <div class="navbar bg-base-100">
      <div class="flex-none">
        <button class="btn btn-square btn-ghost">
          <.icon name="hero-bars-3" class="size-5 shrink-0" />
        </button>
      </div>
      <div class="flex-1">
        <a class="btn btn-ghost text-xl">Librex</a>
      </div>
      <div class="flex-none">
        <div class="scale-sm">
          <.theme_toggle />
        </div>
      </div>
    </div>
    """
  end
end
