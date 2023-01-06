defmodule BlogBackendWeb.UserController do
  use BlogBackendWeb, :controller

  import BlogBackend.Auth

  alias BlogBackend.Auth
  alias BlogBackend.Guardian
  alias BlogBackendWeb.FallbackController

  action_fallback FallbackController

  @spec index(Plug.Conn.t(), map) :: FallbackController.t()
  def index(conn, %{"search" => search}) do
    with users <- search_user(search),
         do: render(conn, "index.json", users: users)
  end

  @spec create(Plug.Conn.t(), map) :: FallbackController.t()
  def create(conn, %{"user" => params}) do
    with {:ok, user} <- create_user(params) do
      conn
      |> put_status(201)
      |> render("id.json", user: user)
    end
  end

  @spec show(Plug.Conn.t(), map) :: FallbackController.t()
  def show(conn, %{"id" => id}) do
    with {:ok, user} <- get_user(id),
         do: render(conn, "show.json", user: user)
  end

  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"id" => id, "changes" => changes}) do
    with(
      {:ok, user} <- get_user(id),
      {:ok, auth_user} <- get_athenticated_user(conn),
      :ok <- Bodyguard.permit(Auth, :update_user, user, auth_user),
      {:ok, _updated_user} <- update_user(user, changes)
    ) do
      render(conn, "id.json", user: user)
    end
  end

  @spec delete(Plug.Conn.t(), map) :: FallbackController.t()
  def delete(conn, %{"id" => id}) do
    with(
      {:ok, user} <- get_user(id),
      {:ok, auth_user} <- get_athenticated_user(conn),
      :ok <- Bodyguard.permit(Auth, :delete_user, user, auth_user),
      {:ok, _deleted_user} <- delete_user(user)
    ) do
      put_status(conn, 204)
    end
  end

  @spec login(Plug.Conn.t(), map) :: FallbackController.t()
  def login(conn, %{
        "credentials" => %{
          "email" => email,
          "password" => password
        }
      }) do
    with(
      :ok <- check_credentials(email, password),
      {:ok, user} <- get_user_by_email(email)
    ) do
      {:ok, token, _claims} = Guardian.encode_and_sign(user, %{"typ" => "access"})
      render(conn, "token.json", token: token)
    end
  end

  def login(conn, %{"credentials" => _}),
    do:
      conn
      |> put_status(422)
      |> put_view(BlogBackendWeb.ErrorView)
      |> render("422.json")
end
