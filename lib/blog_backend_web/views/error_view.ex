defmodule BlogBackendWeb.ErrorView do
  use BlogBackendWeb, :view

  import BlogBackendWeb.ChangesetHelpers

  def render("error.json", %{changeset: changeset, message: message}) do
    %{
      payload: put_changes(changeset),
      errors: put_errors(changeset, message)
    }
  end

  def render("error.json", %{message: message}) do
    %{
      errors: put_errors(message)
    }
  end

  def render("error.json", %{changeset: changeset}) do
    %{
      payload: put_changes(changeset),
      errors: put_errors(changeset)
    }
  end
end
