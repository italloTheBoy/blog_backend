defmodule BlogBackendWeb.UserView do
  use BlogBackendWeb, :view

  import BlogBackendWeb.ChangesetHelpers

  def render("register_error.json", %{changeset: changeset}) do
    %{
      message: "Não foi possivel concluír o registro",
      data: put_changes(changeset),
      errors: put_errors(changeset)
    }
  end
end
