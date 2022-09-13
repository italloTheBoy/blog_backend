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

  def render("show.json", %{user: %User{id: id, username: username, email: email}}) do
    %{
      message: "Usuario solicitado encontrado",
      user: %{
        id: id,
        email: email,
        username: username
      }
    }
  end

  def render("show.json", _params) do
    %{message: "Não foi possivel encontrar o usuario solicitado"}
  end

  def render("delete.json", %{is_deleted: is_deleted})
      when is_deleted do
    %{message: "Usuario excluido"}
  end

  def render("delete.json", %{is_deleted: is_deleted})
      when is_deleted == false do
    %{message: "Não foi possivel excluir o usuario"}
  end
end
