defmodule PracticeMate.Spotify.Request do
  @moduledoc """
  This module houses the basic list of requests used to interact with spotify as well as handling responses 
  in a basic manner
  """
  alias Req
  require Logger

  @api_url "https://api.spotify.com/v1/"
  @token_url "https://accounts.spotify.com/api/token"
  @auth_url "https://accounts.spotify.com/authorize"

  # Would likely want to change this in a non-dev env
  @redirect_uri "http://localhost:4000/spotify"

  @doc """
  Generates the authorization url with user permissions needed to run this application
  """
  @spec authorize() :: String.t()
  def authorize() do
    params = [
      scope: "user-read-playback-state user-modify-playback-state user-read-currently-playing",
      client_id: System.get_env("CLIENT_ID"),
      redirect_uri: "http://localhost:4000"
    ]

    [method: :get, url: @auth_url, params: params]
    |> Req.new()
    |> Req.run!()

    @auth_url
    |> URI.parse()
    |> URI.append_query(
      "scope=user-read-playback-state user-modify-playback-state user-read-currently-playing"
    )
    |> URI.append_query("client_id=#{client_id()}")
    |> URI.append_query("redirect_uri=#{@redirect_uri}")
    |> URI.append_query("response_type=code")
    |> URI.to_string()
  end

  @doc """
  This function retrieves the access token from the API and allows us to make subsequent requests

  Docs: https://developer.spotify.com/documentation/web-api/tutorials/getting-started#request-an-access-token
  """
  @spec get_access_token(String.t()) :: {:ok, map()}
  def get_access_token(code) do
    auth_header = Base.encode64("#{client_id()}:#{client_secret()}")

    headers = [
      {"content-type", "application/x-www-form-urlencoded"},
      {"Authorization", "Basic #{auth_header}"}
    ]

    body = "grant_type=authorization_code&code=#{code}&redirect_uri=#{@redirect_uri}"

    request = Req.new(method: :post, url: @token_url, headers: headers, body: body)

    {:ok, response} = Req.request(request)

    token = response.body["access_token"]
    refresh_token = response.body["refresh_token"]

    {:ok, %{token: token, refresh_token: refresh_token}}
  end

  @doc "Gets the playlist of specified ID"
  @spec get_playlist(String.t()) :: list(PracticeMate.Spotify.song())
  def get_playlist(playlist_id) do
    # expires, use for dev
    {:ok, response} =
      Req.new(method: :get, url: @api_url <> "playlists/#{playlist_id}", headers: auth_headers())
      |> Req.request()

    tracks = get_in(response.body, ["tracks", "items"])

    Enum.map(tracks, fn track ->
      track = track["track"]

      artists =
        track["artists"]
        |> Enum.map(& &1["name"])
        |> Enum.join(", ")

      %{
        name: track["name"],
        id: track["id"],
        artist: artists
      }
    end)
  end

  @doc "Plays the specified track"
  @spec play_track(String.t()) :: :ok | :error
  def play_track(_track_id) do
    # Not implemented
    Enum.random([:ok, :error])
  end

  @doc """
  Stops playback on the current device
  curl --request PUT \
  --url https://api.spotify.com/v1/me/player/pause \
  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
  """
  @spec pause_playback() :: :ok
  def pause_playback(device_id \\ "") do
    Req.new(
      method: :put,
      url: @api_url <> "me/player/pause",
      headers: auth_headers(),
      body: "device=#{device_id}"
    )
    |> Req.request()
    |> case do
      {:ok, %Req.Response{status: 200}} -> :ok
      _ -> raise "This beat can't be stopped"
    end
  end

  @doc """
  Gets the currently playing track
  """
  @spec currently_playing() :: {:ok, map()} | :error
  def currently_playing() do
    Req.new(method: :get, url: @api_url <> "me/player/currently-playing", headers: auth_headers())
    |> Req.request()
    |> case do
      {:ok, %{status: 200, body: body}} ->
        id = get_in(body, ["item", "id"])
        name = get_in(body, ["item", "name"])
        artist = get_in(body, ["item", "artist"])
        {:ok, %{id: id, name: name, artist: artist}}

      _error ->
        Logger.warning("Could not get the currently playing song")
        :error
    end
  end

  @doc """
  Gets the device currently available for playback
  """
  @spec active_device() :: {:ok, map()} | :error
  def active_device() do
    Req.new(method: :get, url: @api_url <> "me/player/devices", headers: auth_headers())
    |> Req.request()
    |> case do
      {:ok, %{status: 200, body: body}} ->
        device = Enum.find(body["devices"], &(&1["is_active"] == true))
        {:ok, %{id: device["id"], name: device["name"], volume: device["volume_percent"]}}

      _error ->
        Logger.warning("Could not find devices")
        :error
    end
  end

  @doc """
  Gets the ID associated to the learning playlist from the env
  not strictly necessary but makes mocking easier if it lives in the module
  """
  @spec learning_playlist_id() :: String.t()
  def learning_playlist_id() do
    case System.get_env("SPOTIFY_LEARNING_PLAYLIST_ID") do
      nil ->
        raise "Please set SPOTIFY_CLIENT_SECRET in your environment"

      secret ->
        secret
    end
  end

  defp auth_headers() do
    [{"authorization", "Bearer #{token()}"}]
  end

  defp token() do
    PracticeMate.TokenStore.spotify_token()
  end

  @spec client_id() :: String.t()
  defp client_id() do
    case System.get_env("SPOTIFY_CLIENT_ID") do
      nil ->
        raise "Please set SPOTIFY_CLIENT_ID in your environment"

      client_id ->
        client_id
    end
  end

  defp client_secret() do
    case System.get_env("SPOTIFY_CLIENT_SECRET") do
      nil ->
        raise "Please set SPOTIFY_CLIENT_SECRET in your environment"

      secret ->
        secret
    end
  end

  # TODO - Should be used for user related functions, when implemented
  #  @spec user_id() :: String.t()
  #  defp user_id() do
  #    case System.get_env("SPOTIFY_USER_ID") do
  #      nil ->
  #        raise "Please set SPOTIFY_USER_ID in your environment"
  #
  #      user_id ->
  #        user_id
  #    end
  #  end
end
