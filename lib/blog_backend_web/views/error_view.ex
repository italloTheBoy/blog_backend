defmodule BlogBackendWeb.ErrorView do
  use BlogBackendWeb, :view

  import BlogBackendWeb.ChangesetHelpers
  import Phoenix.Controller

  def render("error.json", %{changeset: changeset, message: message}) do
    %{
      payload: put_changes(changeset),
      errors: put_errors(changeset, message)
    }
  end

  def render("error.json", %{message: message}) do
    %{
      errors: put_errors(message)
    }
  end

  def render("error.json", %{changeset: changeset}) do
    %{
      payload: put_changes(changeset),
      errors: put_errors(changeset)
    }
  end

  def template_unauthorized(template, _assigns),
    do: %{errors: %{message: status_message_from_template(template)}}

  def template_forbidden(template, _assigns),
    do: %{errors: %{message: status_message_from_template(template)}}

  def template_not_found(template, _assigns),
    do: %{errors: %{message: status_message_from_template(template)}}

  def template_unprocessable_entity(template, _assigns),
    do: %{errors: %{message: status_message_from_template(template)}}

  def template_internal_server_error(template, _assigns),
    do: %{errors: %{message: status_message_from_template(template)}}
end
