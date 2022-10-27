defmodule BlogBackendWeb.PostController do
  use BlogBackendWeb, :controller

  import BlogBackend.Timeline

  alias BlogBackend.Timeline.Post

  @type post_payload() :: %{
    optional(:title) => String.t(),
    optional(:body) => String.t(),
    optional(:user_id) => Integer.t(),
    optional(:user) => %{required(:id) => Integer.t()}
  }

  @spec create(Plug.Conn.t(), post_payload()) :: Plug.Conn.t()
  def create(conn, params) do
    params
    |> create_post()
    |> case do
      {:ok, %Post{} = post} ->
        conn
        |> put_status(201)
        |> render("create.json", status: 201, post: post)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(422)
        |> render("create.json", status: 422, changeset: changeset)
    end
  end
end
