defmodule BlogBackend.TestHelpers do
  def render(module, template, assigns),
    do:
      module
      |> Phoenix.View.render(template, assigns)
      |> Jason.encode!()
      |> Jason.decode!()
end
