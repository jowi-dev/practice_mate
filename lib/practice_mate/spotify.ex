defmodule PracticeMate.Spotify do
  alias PracticeMate.Spotify.Request

  defdelegate authorize_url(), to: Request, as: :authorize

  defdelegate authorize_token(code), to: Request, as: :get_access_token
end
