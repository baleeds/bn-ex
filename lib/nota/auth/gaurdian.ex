defmodule Nota.Auth.Guardian do
  @moduledoc false

  use Guardian, otp_app: :nota

  alias Nota.Auth

  require Ecto

  # TODO: do I need to validate JTI in here?

  def subject_for_token(%{user_id: _} = resource, _), do: {:ok, resource}

  def subject_for_token(_resource, _claims), do: {:error, "invalid JWT resource"}

  def subject_for_token(resource, claims) do
    IO.inspect(resource, label: "resource")
    IO.inspect(claims, label: "claims")
    {:error, "wut"}
  end

  def resource_from_claims(%{"sub" => %{"user_id" => user_id}}) do
    case Auth.get_user(user_id) do
      nil ->
        {:error, :unauthenticated}

      user ->
        {:ok, user}
    end
  end

  def resource_from_claims(_claims), do: {:error, "invalid JWT claims"}
end
