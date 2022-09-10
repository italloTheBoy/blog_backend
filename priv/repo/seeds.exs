# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BlogBackend.Repo.insert!(%BlogBackend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

BlogBackend.Auth.change_user(%BlogBackend.Auth.User{}, %{
    password: "aaaaaaaaaaaaaaaaaaaaaaaaaaa",
    username: "itallo",
    email: "itallo@gmail.com"
  })
|> IO.inspect()
