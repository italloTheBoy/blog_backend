defmodule BlogBackendWeb.GlobalView do
  use BlogBackendWeb, :view

  def render("count.json", %{count: count}),
    do: %{
      data: %{count: count}
    }
end
