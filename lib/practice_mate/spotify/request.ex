defmodule PracticeMate.Spotify.Request do
  @moduledoc """
  This module houses the basic list of requests used to interact with spotify as well as handling responses 
  in a basic manner
  """
  alias Req

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
  @spec get_playlist(String.t()) :: :ok
  def get_playlist(playlist_id) do
    # expires, use for dev
    Req.new(method: :get, url: @api_url <> "playlists/#{playlist_id}", headers: auth_headers())
    |> Req.request()
    |> IO.inspect(limit: :infinity, pretty: true, label: "what's this")

    # .body["tracks"]
    :ok
  end

  @doc "Plays the specified track"
  @spec play_track(String.t()) :: :ok
  def play_track(_track_id) do
    # Req.new(method: 

    :ok
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

  def currently_playing() do
    Req.new(method: :get, url: @api_url <> "me/player/currently-playing", headers: auth_headers())
    |> Req.request()
  end

  def devices() do
    Req.new(method: :get, url: @api_url <> "me/player/devices", headers: auth_headers())
    |> Req.request()
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

  @spec user_id() :: String.t()
  defp user_id() do
    case System.get_env("SPOTIFY_USER_ID") do
      nil ->
        raise "Please set SPOTIFY_USER_ID in your environment"

      user_id ->
        user_id
    end
  end
end
