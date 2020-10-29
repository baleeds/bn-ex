defmodule NotaWeb.Schema.Auth do
  import AbsintheErrorPayload.Payload

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias NotaWeb.Resolvers.Auth

  # import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  import NotaWeb.Schema.Helpers, only: [to_global_id: 1]

  connection(node_type: :user)

  node object(:user) do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, non_null(:string))

    # field(:annotations, list_of(non_null(:annotation)), resolve: dataloader(Annotations.Annotation))
  end

  object :session_info do
    field(:access_token, non_null(:string))
    field(:refresh_token, :string)
    field(:user_id, :id, resolve: to_global_id(:user))
  end

  object :auth_queries do
    field :user, non_null(:user) do
      arg(:id, non_null(:id))

      resolve(&Auth.get_user/3)
    end

    # connection field(:users, node_type: :user) do
    #   resolve(&User.get_users/3)
    # end

    field :me, :user do
      resolve(&Auth.get_me/3)
    end
  end

  input_object(:create_account_input) do
    field(:email, non_null(:string))
    field(:password, non_null(:string))
    field(:first_name, non_null(:string))
    field(:last_name, :string)
  end

  input_object(:sign_in_input) do
    field(:email, non_null(:string))
    field(:password, non_null(:string))
  end

  payload_object(:create_account_payload, :user)

  payload_object(:sign_in_payload, :session_info)

  object :auth_mutations do
    field :create_account, non_null(:create_account_payload) do
      arg(:input, non_null(:create_account_input))

      resolve(&Auth.create_account/3)
    end

    field(:sign_in, non_null(:sign_in_payload)) do
      arg(:input, non_null(:sign_in_input))

      resolve(&Auth.sign_in/3)
    end

    field :refresh_token, non_null(:string) do
      arg(:token, non_null(:string))

      resolve(&Auth.refresh_token/3)
    end
  end
end
