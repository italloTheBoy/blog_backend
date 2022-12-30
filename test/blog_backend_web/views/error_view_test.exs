defmodule BlogBackendWeb.ErrorViewTest do
  use BlogBackendWeb.ConnCase, async: true

  import BlogBackendWeb.ErrorView

  alias BlogBackendWeb.ErrorView

  @moduletag :error_view

  @tag error_view: "401"
  test "renders 401.json" do
    assert render(ErrorView, "401.json") == %{
             errors: %{detail: "Unauthorized"}
           }
  end

  @tag error_view: "403"
  test "renders 403.json" do
    assert render(ErrorView, "403.json") == %{
             errors: %{detail: "Forbidden"}
           }
  end

  @tag error_view: "404"
  test "renders 404.json" do
    assert render(ErrorView, "404.json") == %{
             errors: %{detail: "Not Found"}
           }
  end

  @tag error_view: "422"
  test "renders 422.json" do
    assert render(ErrorView, "422.json") == %{
             errors: %{detail: "Unprocessable Entity"}
           }
  end

  @tag error_view: "500"
  test "renders 500.json" do
    assert render(ErrorView, "500.json") == %{
             errors: %{detail: "Internal Server Error"}
           }
  end
end
