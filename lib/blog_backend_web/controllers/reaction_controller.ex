defmodule BlogBackendWeb.ReactionController do
  use BlogBackendWeb, :controller

  alias Phoenix.LiveView.Plug
  alias BlogBackend.Timeline
  alias BlogBackend.Timeline.Reaction
  alias BlogBackendWeb.FallbackController

  action_fallback BlogBackendWeb.FallbackController

  @spec create(Plug.Conn.t(), map) :: FallbackController.t()
  def create(conn, params) do
    with {:ok, %Reaction{} = reaction} <- Timeline.create_reaction(params) do
      conn
      |> put_status(201)
      |> put_resp_header("location", Routes.reaction_path(conn, :show, reaction))
      |> render("show.json", reaction: reaction, message: "Created")
    end
  end

  @spec show(Plug.Conn.t(), map) :: FallbackController.t()
  def show(conn, %{"id" => id}) do
    with {:ok, %Reaction{} = reaction} <- Timeline.get_reaction(id) do
      render(conn, "show.json", reaction: reaction)
    end
  end

  @spec update(Plug.Conn.t(), map) :: FallbackController.t()
  def update(conn, %{"id" => id}) do
    with(
      {:ok, %Reaction{} = reaction} = Timeline.get_reaction(id),
      {:ok, %Reaction{} = updated_reaction} <- Timeline.toggle_reaction_type(reaction)
    ) do
      render(conn, "show.json", reaction: updated_reaction)
    end
  end

  @spec delete(Plug.Conn.t(), map) :: FallbackController.t()
  def delete(conn, %{"id" => id}) do
    with(
      {:ok, %Reaction{} = reaction} = Timeline.get_reaction(id),
      {:ok, %Reaction{} = deleted_reaction} <- Timeline.delete_reaction(reaction)
    ) do
      render(conn, "show.json", reaction: deleted_reaction)
    end
  end
end
