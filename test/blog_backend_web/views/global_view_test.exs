defmodule BlogBackendWeb.GlobalViewTest do
  use BlogBackendWeb.ConnCase, async: true

  alias Phoenix.View
  alias BlogBackendWeb.GlobalView

  @moduletag :global_view

  @tag global_view: "count"
  test "renders count number" do
    ramdom_number = Enum.random(1..100)

    assert ramdom_number == View.render(GlobalView, "count.json", count: ramdom_number).data.count
  end
end
