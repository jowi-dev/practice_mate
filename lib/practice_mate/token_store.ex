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

  @doc """
  Saves the given token and refresh token to the cache for later lookup
  """
  @spec put_spotify_token(map(), boolean()) :: :ok
  def put_spotify_token(token_map, recurse? \\ false) do
    case {Registry.lookup(Registry, Spotify), recurse?} do
      {{:ok, pid}, _} ->
        for {k, v} <- token_map do
          Bucket.put(pid, k, v)
        end

        :ok

      {:error, true} ->
        raise "Failed to save spotify token #{inspect(token_map)}"

      _error ->
        :ok = Registry.create(Registry, Spotify)
        put_spotify_token(token_map, true)
    end
  end

  @spec active_song() :: Spotify.song() | nil
  def active_song() do
    case Registry.lookup(Registry, Spotify) do
      {:ok, pid} ->
        Bucket.get(pid, :active_song)

      _error ->
        Registry.create(Registry, Spotify)
        nil
    end
  end

  @spec set_active_song(Spotify.song(), boolean()) :: :ok
  def set_active_song(song, recurse? \\ false) do
    case {Registry.lookup(Registry, Spotify), recurse?} do
      {{:ok, pid}, _} ->
        Bucket.put(pid, :active_song, song)
        :ok

      {:error, true} ->
        raise "Failed to save active song #{inspect(song)}"

      _error ->
        :ok = Registry.create(Registry, Spotify)
        set_active_song(song, true)
    end
  end
end
