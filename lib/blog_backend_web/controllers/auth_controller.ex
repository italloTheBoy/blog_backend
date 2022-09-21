defmodule BlogBackendWeb.AuthController do
  use BlogBackendWeb, :controller

  alias BlogBackend.Auth
  alias BlogBackend.Auth.{User, User.Guardian}

  @spec login(Plug.Conn.t(), map) :: Plug.Conn.t()
  def login(conn, params = %{"email" => email, "password" => password}) do
    case Auth.auth_user(email, password) do
      {:ok, user} ->
        {:ok, jwt, _claims} = Guardian.encode_and_sign(user)
        # IO.inspect(jwt)

        conn
        |> put_req_header("authorization", "Bearer " <> jwt)
        |> render("login.json", current_user: user)

      {:error, _reason} ->
        conn
        |> put_status(422)
        |> render("login.json", data: params)
    end
  end
end
