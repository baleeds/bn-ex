defmodule NotaWeb.Schema do
  import AbsintheErrorPayload.Payload

  use Absinthe.Schema
  use Absinthe.Relay.Schema, flavor: :modern
  use Absinthe.Relay.Schema.Notation, :modern

  alias Nota.Bible
  alias Nota.Annotations
  alias Nota.Auth

  import_types(AbsintheErrorPayload.ValidationMessageTypes)
  import_types(Absinthe.Type.Custom)

  import_types(__MODULE__.Bible)
  import_types(__MODULE__.Annotations)
  import_types(__MODULE__.Users)

  query do
    import_fields(:bible_queries)
    import_fields(:annotations_queries)
    import_fields(:user_queries)
  end

  mutation do
    import_fields(:annotations_mutations)
    import_fields(:user_mutations)
  end

  node interface do
    resolve_type(fn
      %Nota.Annotations.Annotation{}, _ ->
        :annotation

      %Nota.Auth.User{}, _ ->
        :user

      _, _ ->
        nil
    end)
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Bible.Verse, Bible.data())
      |> Dataloader.add_source(Annotations.Annotation, Annotations.data())
      |> Dataloader.add_source(Auth.User, Auth.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middleware, _field, %Absinthe.Type.Object{identifier: :mutation}) do
    middleware ++
      [&build_payload/2]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end
end
