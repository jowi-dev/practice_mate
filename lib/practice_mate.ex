defmodule PracticeMate do
  @moduledoc """
  PracticeMate keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias PracticeMate.{TokenStore, Spotify}

  @doc """
  Uses the authorization code from spotify to generate a token that 
  can be used for authentication
  """
  @spec save_authorization(String.t()) :: :ok
  def save_authorization(code) do
    {:ok, token_map} = Spotify.authorize_token(code)
    :ok = TokenStore.put_spotify_token(token_map)

    :ok
  end

  @doc """
  Selects a song from a list given user input, and plays the given song
  """
  @spec select_song(Elixir.Module.t()) :: :ok | {:error, :invalid_selection}
  def select_song(io_module \\ IO) do
    {:ok, playlist} = Spotify.learning_playlist()
    io_module.puts("*** Song Selection ***")

    playlist = Enum.with_index(playlist, 1)

    Enum.each(playlist, fn {song, idx} ->
      io_module.puts("#{idx}. #{song.artist}: #{song.name}")
    end)

    selection =
      io_module.gets("Select a song by number: ")
      |> String.replace("\n", "")
      |> String.to_integer()

    playlist
    |> Enum.find(fn {_song, idx} -> idx == selection end)
    |> case do
      nil ->
        {:error, :invalid_selection}

      {song, _idx} ->
        Spotify.play_track(song.id)
        TokenStore.set_active_song(song)
    end
  end
end
