defmodule BlogBackend.Timeline.Policy do
  @behaviour Bodyguard.Policy

  alias BlogBackend.Timeline.Comment
  alias BlogBackend.Timeline.Post
  alias BlogBackend.Timeline.Reaction
  alias BlogBackend.Auth.User

  @easy_access_actions [:create_post, :create_comment, :create_reaction]
  @hard_access_actions [
    :show_reaction,
    :update_reaction,
    :delete_post,
    :delete_comment,
    :delete_reaction
  ]

  @spec authorize(
          atom,
          User.t(),
          Post.t() | Comment.t() | Reaction.t()
        ) :: :ok | :error
  def authorize(action, %User{}, _params)
      when action in @easy_access_actions,
      do: :ok

  def authorize(action, %User{id: user_id}, %{user_id: user_id})
      when action in @hard_access_actions,
      do: :ok

  def authorize(_action, _user, _params), do: {:error, :forbidden}
end
