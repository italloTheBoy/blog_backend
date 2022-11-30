defmodule BlogBackend.Auth.Pipeline.PutCurrentUser do
  alias BlogBackend.Auth.Guardian

  import Plug.Conn
  import Guardian.Plug

  def init(params), do: params

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _params), do: assign(conn, :current_user, current_resource(conn))
end
