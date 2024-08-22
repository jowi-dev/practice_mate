defmodule PracticeMate do
  @moduledoc """
  PracticeMate keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias PracticeMate.TokenStore

  def save_authorization(code) do
    {:ok, pid} = TokenStore.Registry.lookup(TokenStore.Registry, PracticeMate.Spotify)
    {:ok, token_map} = PracticeMate.Spotify.authorize_token(code)

    for {k, v} <- token_map do
      TokenStore.Bucket.put(pid, k, v)
    end

    :ok
  end
end
