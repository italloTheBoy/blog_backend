defmodule BlogBackendWeb.UserView do
  use BlogBackendWeb, :view

  import BlogBackendWeb.ChangesetHelpers

  alias BlogBackend.Auth.User

  def render("register.json", %{new_user: new_user = %User{}}) do
    %{
      message: "Registro concluído",
      new_user_id: new_user.id
    }
  end


  def render("register.json", %{changeset: changeset}) do
    %{
      message: "Não foi possivel concluír o registro",
      data: put_changes(changeset),
      errors: put_errors(changeset)
    }
  end
end
