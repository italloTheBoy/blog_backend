defmodule BlogBackendWeb.UserView do
  use BlogBackendWeb, :view

  import BlogBackendWeb.ChangesetHelpers

  alias BlogBackend.Auth.User

  def render("register.json", %{new_user: new_user = %User{}}) do
    %{
      message: "registro concluído",
      new_user_id: new_user.id
    }
  end

  def render("register.json", %{changeset: changeset}) do
    %{
      message: "não foi possivel concluír o registro",
      data: put_changes(changeset),
      errors: put_errors(changeset)
    }
  end

  def render("show.json", %{user: user = %User{}}) do
    %{
      message: "usuario solicitado encontrado",
      user: render("user.json", user: user)
    }
  end

  def render("show.json", _params) do
    %{message: "não foi possivel encontrar o usuario solicitado"}
  end

  def render("update.json", %{updated_user: updated_user}) do
    %{
      message: "os dados do usuario foram atualizados",
      user: render("user.json", user: updated_user)
    }
  end

  def render("update.json", %{changeset: changeset}) do
    %{
      message: "não foi possivel atuazlizar os dados do usuario",
      data: put_changes(changeset),
      errors: put_errors(changeset)
    }
  end

  def render("delete.json", %{is_deleted: is_deleted})
      when is_deleted do
    %{message: "usuario excluido"}
  end

  def render("delete.json", %{is_deleted: is_deleted})
      when is_deleted == false do
    %{message: "não foi possivel excluir o usuario"}
  end

  def render("user.json", %{user: user}) do
    Map.take(
      user,
      [:id, :email, :username, :inserted_at, :updated_at]
    )
  end
end
