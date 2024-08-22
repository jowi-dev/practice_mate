defmodule PracticeMate.Support.MockSpotifyRequest do
  @moduledoc """
  This module should match the functions in PracticeMate.Spotify.Request
  and is used to hardcode returns for more explicit testing
  """
  def authorize(), do: "https://localhost.spotify.com/logmein"

  def get_access_token(_code) do
    {:ok, %{token: "goodtoken", refresh_token: "sorefreshing"}}
  end

  def learning_playlist_id(), do: "learning"

  def get_playlist("learning") do
    [
      %{
        name: "Welcome to Miami",
        artist: "Will Smith",
        id: "390484auadfmkls"
      },
      %{
        name: "Good Vibrations",
        artist: "Marky Mark and the Funky Bunch",
        id: "584975dsfnjgkhsjd"
      },
      %{
        name: "I Kissed a Girl",
        artist: "Katy Perry",
        id: "badtrack"
      }
    ]
  end

  def play_track("badtrack"), do: :error
  def play_track(_track_id), do: :ok

  def active_device(), do: {:ok, %{id: "gooddevice"}}

  def play("gooddevice"), do: :ok

  def pause_playback("gooddevice"), do: :ok
end
