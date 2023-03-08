defmodule BlogBackendWeb.ReactionController do
  use BlogBackendWeb, :controller

  import BlogBackend.{Auth, Timeline}

  alias BlogBackend.Timeline
  alias BlogBackendWeb.FallbackController

  action_fallback BlogBackendWeb.FallbackController

  @spec index(Plug.Conn.t(), map) :: FallbackController.t()
  def index(conn, %{"user_id" => id}) do
    with(
      {:ok, user} <- get_user(id),
      reactions <- list_user_reactions(user)
    ) do
      render(conn, "index.json", reactions: reactions)
    end
  end

  @spec create(Plug.Conn.t(), map) :: FallbackController.t()
  def create(conn, %{"post_id" => father_id, "reaction" => params}) do
    with(
      {:ok, user} <- get_athenticated_user(conn),
      {:ok, reaction} <-
        params
        |> Map.merge(%{"user_id" => user.id, "post_id" => father_id})
        |> create_reaction()
    ) do
      conn
      |> put_status(201)
      |> render("id.json", reaction: reaction)
    end
  end

  def create(conn, %{"comment_id" => father_id, "reaction" => params}) do
    with(
      {:ok, user} <- get_athenticated_user(conn),
      {:ok, reaction} <-
        params
        |> Map.merge(%{"user_id" => user.id, "comment_id" => father_id})
        |> create_reaction()
    ) do
      conn
      |> put_status(201)
      |> render("id.json", reaction: reaction)
    end
  end

  @spec show(Plug.Conn.t(), map) :: FallbackController.t()
  def show(conn, %{"id" => id}) do
    with(
      {:ok, user} <- get_athenticated_user(conn),
      {:ok, reaction} <- get_reaction(id),
      :ok <- Bodyguard.permit(Timeline, :show_reaction, user, reaction)
    ) do
      render(conn, "show.json", reaction: reaction)
    end
  end

  def show(conn, %{"post_id" => father_id}) do
    with(
      {:ok, user} <- get_athenticated_user(conn),
      {:ok, reaction} <-
        get_reaction_by_fathers(%{
          user_id: user.id,
          post_id: father_id
        }),
      :ok <- Bodyguard.permit(Timeline, :show_reaction, user, reaction)
    ) do
      render(conn, "show.json", reaction: reaction)
    end
  end

  def show(conn, %{"comment_id" => father_id}) do
    with(
      {:ok, user} <- get_athenticated_user(conn),
      {:ok, reaction} <-
        get_reaction_by_fathers(%{
          user_id: user.id,
          comment_id: father_id
        }),
      :ok <- Bodyguard.permit(Timeline, :show_reaction, user, reaction)
    ) do
      render(conn, "show.json", reaction: reaction)
    end
  end

  @spec update(Plug.Conn.t(), map) :: FallbackController.t()
  def update(conn, %{"id" => id}) do
    with(
      {:ok, user} <- get_athenticated_user(conn),
      {:ok, reaction} <- get_reaction(id),
      :ok <- Bodyguard.permit(Timeline, :update_reaction, user, reaction),
      {:ok, updated_reaction} <- toggle_reaction_type(reaction)
    ) do
      render(conn, "id.json", reaction: updated_reaction)
    end
  end

  @spec delete(Plug.Conn.t(), map) :: FallbackController.t()
  def delete(conn, %{"id" => id}) do
    with(
      {:ok, user} <- get_athenticated_user(conn),
      {:ok, reaction} <- get_reaction(id),
      :ok <- Bodyguard.permit(Timeline, :update_reaction, user, reaction),
      {:ok, _deleted_reaction} <- delete_reaction(reaction)
    ) do
      send_resp(conn, 204, "")
    end
  end
end
