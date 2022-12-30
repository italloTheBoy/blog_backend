defmodule BlogBackend.TestHelpers do
  def render(module, template, assigns),
    do:
      module
      |> Phoenix.View.render(template, assigns)
      |> Jason.encode!()
      |> Jason.decode!()

  def render_one(resource, template, module, assigns \\ %{}),
    do:
      resource
      |> Phoenix.View.render_one(template, module, assigns)
      |> Jason.encode!()
      |> Jason.decode!()

  @spec select_random_fields(list) :: list
  def select_random_fields(fields)
      when is_list(fields),
      do: Enum.take_random(fields, Enum.random(0..length(fields)))
end
