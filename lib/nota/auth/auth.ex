defmodule Nota.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Nota.Repo
  alias Nota.Auth.User
  alias Nota.Auth.Guardian

  def data() do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  def get_users(), do: User

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def upsert_user(auth) do
    with {:ok, user_or_nil} <- find_user_by_oauth(auth),
         attrs <- get_user_changes(auth) do
      case user_or_nil do
        nil -> create_user(attrs)
        user -> update_user(user, attrs)
      end
    else
      {:error, error} -> {:error, error}
    end
  end

  defp find_user_by_oauth(%{provider: oauth_provider, uid: oauth_uid}) do
    stringified_oauth_provider = Atom.to_string(oauth_provider)

    User
    |> where([u], u.oauth_provider == ^stringified_oauth_provider and u.oauth_uid == ^oauth_uid)
    |> Repo.one()
    |> case do
      user_or_nil -> {:ok, user_or_nil}
    end
  end

  defp find_user_by_oauth(_), do: {:error, "Invalid oauth information"}

  defp get_user_changes(%{
         provider: provider,
         uid: uid,
         credentials: %{
           token: token,
           refresh_token: refresh_token,
           expires: expires,
           expires_at: expires_at
         },
         info: %{
           email: email,
           first_name: first_name,
           last_name: last_name
         }
       }) do
    %{
      email: email,
      first_name: first_name,
      last_name: last_name,
      oauth_provider: Atom.to_string(provider),
      oauth_uid: uid,
      oauth_token: token,
      oauth_refresh_token: refresh_token,
      oauth_expires_at: expires_at,
      oauth_expires: expires
    }
    |> IO.inspect()
  end

  # TODO: this is duplicate from user resolver
  # TODO: also, rename this authorization_token so it's clearer
  def get_user_authorization_token(%{id: user_id}) do
    %{
      user_id: user_id
    }
    |> Guardian.encode_and_sign()
    |> case do
      {:ok, token, claims} ->
        # TODO: perist JTI from claims on user
        {:ok, %{token: token, claims: claims}}

      _ ->
        {:error, "unable to get user authorization"}
    end
  end

  def refresh_user_authorization_token(token) do
    Guardian.refresh(token)
    |> case do
      {:ok, _old_stuff, {new_token, _new_claims}} -> {:ok, new_token}
      _ -> {:error, "unable to refresh token"}
    end
  end
end
