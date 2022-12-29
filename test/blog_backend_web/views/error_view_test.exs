defmodule BlogBackendWeb.ErrorViewTest do
  use BlogBackendWeb.ConnCase, async: true

  test "renders 404.json" do
    assert render(BlogBackendWeb.ErrorView, "404.json", []) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500.json" do
    assert render(BlogBackendWeb.ErrorView, "500.json", []) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
