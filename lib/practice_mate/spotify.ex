defmodule PracticeMate.Spotify do
  @moduledoc """
  Provides the base API for interacting with Spotify
  """

  @type song :: %{
          name: String.t(),
          artist: String.t(),
          id: String.t()
        }

  @spotify_request Application.compile_env(:practice_mate, [:behaviours, :spotify_request])

  def authorize_url() do
    @spotify_request.authorize()
  end

  def authorize_token(code) do
    @spotify_request.get_access_token(code)
  end

  @doc """
  Returns the playlist associated with songs we want to learn
  """
  @spec learning_playlist() :: {:ok, list(song())}
  def learning_playlist() do
    learning_playlist_id = @spotify_request.learning_playlist_id()
    playlist = @spotify_request.get_playlist(learning_playlist_id)

    {:ok, playlist}
  end

  @doc """
  Plays the specified track on the current playback device
  """
  @spec play_track(String.t()) :: {:ok, String.t()} | :error
  def play_track(track_id) do
    case @spotify_request.play_track(track_id) do
      :ok -> {:ok, track_id}
      _error -> :error
    end
  end

  @doc """
  Starts or Resumes playback on the currently active device
  """
  @spec play() :: :ok
  def play() do
    {:ok, %{id: device_id}} = @spotify_request.active_device()
    @spotify_request.play(device_id)
  end

  @doc """
  Pauses the currently active device's playback
  """
  @spec pause() :: :ok
  def pause() do
    {:ok, %{id: device_id}} = @spotify_request.active_device()
    @spotify_request.pause_playback(device_id)
  end
end
