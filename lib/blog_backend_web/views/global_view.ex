defmodule BlogBackendWeb.GlobalView do
  use BlogBackendWeb, :view

  def render("count.json", %{count: count}) when is_number(count),
    do: %{
      data: %{count: count}
    }
end
