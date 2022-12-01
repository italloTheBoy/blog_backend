defmodule BlogBackend.Auth.Pipeline.EnsureLogin do
  import Plug.Conn
  import Phoenix.Controller

  def init(params), do: params

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _params) do
    user_id = conn.path_params["user_id"] || conn.path_params["id"]
    current_user = Guardian.Plug.current_resource(conn)

    if current_user.id == String.to_integer(user_id) do
      conn
    else
      conn
      |> put_status(401)
      |> json(%{messge: "Unauthorized"})
      |> halt()
    end
  end
end
