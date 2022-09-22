defmodule BlogBackend.Auth.ErrorHandler do
  import Plug.Conn
  import Phoenix.Controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    error_body = to_string(type)

    conn
    |> put_status(401)
    |> json(%{error: error_body})
  end
end
