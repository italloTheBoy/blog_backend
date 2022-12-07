defmodule BlogBackend.AuthFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BlogBackend.Auth` context.
  """

  alias BlogBackend.Auth

  @doc """
  Generate a unique user email.
  """
  def unique_user_email, do: "somemail#{System.unique_integer([:positive])}@gmail.com"

  @doc """
  Generate a unique user username.
  """
  def unique_user_username, do: "some_username#{System.unique_integer([:positive])}"

  @doc """
  Generate a user.
  """
  @spec user_fixture(map) :: User.t()
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        username: unique_user_username(),
        email: unique_user_email(),
        password: "some password",
        password_confirmation: "some password"
      })
      |> Auth.create_user()

    user
  end
end
