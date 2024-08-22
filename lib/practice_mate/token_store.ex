defmodule PracticeMate.TokenStore do
  @moduledoc """
  This module serves as the data store for our tokens

  This could have been a database, but this felt like a simpler approach
  """

  alias PracticeMate.TokenStore.{Registry, Bucket}
  alias PracticeMate.Spotify

  @doc """
  Get the spotify token from the registry, or create the registry if it is not found
  """
  @spec spotify_token() :: String.t() | nil
  def spotify_token() do
    case Registry.lookup(Registry, Spotify) do
      {:ok, pid} ->
        Bucket.get(pid, :token)

      _error ->
        Registry.create(Registry, Spotify)
        # Return an Empty String
        ""
    end
  end

  @spec put_spotify_token(String.t(), boolean()) :: :ok
  def put_spotify_token(token, recurse? \\ false) do
    case {Registry.lookup(Registry, Spotify), recurse?} do
      {:ok, pid} ->
        Bucket.put(pid, :token, token)

      {:error, true} ->
        raise "Failed to save spotify token #{token}"

      _error ->
        :ok = Registry.create(Registry, Spotify)
        put_spotify_token(token, true)
    end
  end
end
