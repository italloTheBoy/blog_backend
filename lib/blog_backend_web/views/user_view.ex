defmodule BlogBackendWeb.UserView do
  use BlogBackendWeb, :view

  import BlogBackendWeb.ChangesetHelpers

  alias BlogBackend.Auth.User

  def render("register.json", %{user: user = %User{}, token: token}) do
    %{
      message: "registro concluído",
      user: render("user.json", user: user),
      token: token
    }
  end

  def render("register.json", %{changeset: changeset}) do
    %{
      error: %{
        message: "não foi possivel concluír o registro",
        data: put_changes(changeset),
        errors: put_errors(changeset)
      }
    }
  end

  def render("show.json", %{user: user = %User{}}) do
    %{
      message: "usuario solicitado encontrado",
      user: render("user.json", user: user)
    }
  end

  def render("show.json", _params) do
    %{
      error: %{
        message: "não foi possivel encontrar o usuario solicitado"
      }
    }
  end

  def render("update.json", %{updated_user: updated_user = %User{}}) do
    %{
      message: "os dados do usuario foram atualizados",
      user: render("user.json", user: updated_user)
    }
  end

  def render("update.json", %{changeset: changeset}) do
    %{
      error: %{
        message: "não foi possivel atuazlizar os dados do usuario",
        data: put_changes(changeset),
        errors: put_errors(changeset)
      }
    }
  end

  def render("update.json", _params) do
    %{
      error: %{
        message: "não foi possivel encontrar o usuario solicitado"
      }
    }
  end

  def render("delete.json", %{is_deleted: is_deleted})
      when is_deleted do
    %{message: "usuario excluido"}
  end

  def render("delete.json", %{is_deleted: is_deleted})
      when is_deleted == false do
    %{
      error: %{
        message: "não foi possivel excluir o usuario"
      }
    }
  end

  def render("user.json", %{user: user = %User{}}) do
    Map.take(
      user,
      [:id, :email, :username, :inserted_at, :updated_at]
    )
  end
end
