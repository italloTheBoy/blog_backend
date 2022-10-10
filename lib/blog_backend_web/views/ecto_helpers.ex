defmodule BlogBackendWeb.ChangesetHelpers do
  @doc """
  Recive a %Ecto.Changeset{} and return a map with his changes.
  """
  @spec put_changes(Ecto.Changeset.t()) :: map
  def put_changes(changeset = %Ecto.Changeset{}) do
    changeset.changes
  end

  @doc """
    Recive a %Ecto.Changeset{} or an string and return a map with his errors.
  """
  @spec put_errors(Ecto.Changeset.t()) :: map
  def put_errors(changeset = %Ecto.Changeset{}) do
    changeset.errors
    |> Enum.map(fn {k, v} -> {k, elem(v, 0)} end)
    |> Map.new()
  end

  @spec put_errors(String.t) :: map
  def put_errors(global_message) do
    %{ global: global_message }
  end

  @doc """
    Equal put_errors/1 but put the recived string in a error global field.
  """
  @spec put_errors(Ecto.Changeset.t(), String.t) :: map
  def put_errors(changeset = %Ecto.Changeset{}, global_message) do
    Map.put(put_errors(changeset), :global, global_message)
  end
end
