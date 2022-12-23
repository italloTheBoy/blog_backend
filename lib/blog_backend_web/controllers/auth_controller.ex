defmodule BlogBackendWeb.AuthController do
  use BlogBackendWeb, :controller

  alias BlogBackend.Auth
  alias BlogBackend.Auth.User
  alias BlogBackend.Guardian

  @spec login(Plug.Conn.t(), map) :: Plug.Conn.t()
  def login(conn, params = %{"email" => email, "password" => password}) do
    case Auth.auth_user(email, password) do
      {:ok, user = %User{}} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user, %{"typ" => "access"})

        conn
        |> put_status(200)
        |> render("login.json", token: token, user: user)

      {:error, _reason} ->
        conn
        |> put_status(422)
        |> render("login.json", data: params)
    end
  end
end
