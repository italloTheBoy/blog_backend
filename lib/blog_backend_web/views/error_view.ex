defmodule BlogBackendWeb.ErrorView do
  use BlogBackendWeb, :view

  import BlogBackendWeb.ChangesetHelpers

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render("changeset.json", %{changeset: changeset, message: message}) do
    %{
      payload: put_changes(changeset),
      errors: put_errors(changeset, message)
    }
  end

  def render("changeset.json", %{changeset: changeset}) do
    %{
      payload: put_changes(changeset),
      errors: put_errors(changeset)
    }
  end
end
