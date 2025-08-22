defmodule LibrexWeb.Authors.FormLiveTest do
  use LibrexWeb.ConnCase, async: true

  describe "render/1" do
    test "succeeds when valid details are entered", %{conn: conn} do
      conn
      |> visit(~p"/authors/new")
      |> fill_in("Name", with: "Homer")
      |> click_button("Save")
      |> assert_has(flash(:info), text: "Author saved successfully")
    end

    test "shows validation errors", %{conn: conn} do
      conn
      |> visit(~p"/authors/new")
      |> fill_in("Name", with: "Homer")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("name"), text: "is required")
    end

    test "fails when invalid details are entered", %{conn: conn} do
      conn
      |> visit(~p"/authors/new")
      |> fill_in("Name", with: "")
      |> click_button("Save")
      |> assert_has(flash(:error), text: "Could not save author data")
    end
  end
end
