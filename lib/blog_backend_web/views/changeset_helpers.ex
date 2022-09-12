defmodule BlogBackendWeb.ChangesetHelpers do
  @doc """
  Recive a %Ecto.Changeset{} and return a map with his changes.
  """
  @spec put_changes(Ecto.Changeset.t()) :: map
  def put_changes(changeset = %Ecto.Changeset{}) do
    changeset.changes
  end

  @doc """
  Recive a %Ecto.Changeset{} and return a map with his errors.
  """
  @spec put_errors(Ecto.Changeset.t()) :: map
  def put_errors(changeset = %Ecto.Changeset{}) do
    changeset.errors
      |> Enum.map(fn {k, v} -> {k, elem(v, 0)} end)
      |> Map.new()
  end
end
