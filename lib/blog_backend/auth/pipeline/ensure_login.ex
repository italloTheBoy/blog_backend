defmodule BlogBackend.Auth.Pipeline.EnsureLogin do
  import Plug.Conn
  import Phoenix.Controller

  def init(params), do: params

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    user_id = conn.path_params["id"]

    if current_user.id == String.to_integer(user_id) do
      conn
    else
      conn
      |> put_status(401)
      |> json(%{error: :Unauthorized})
      |> halt()
    end
  end
end
