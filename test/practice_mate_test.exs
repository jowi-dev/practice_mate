defmodule PracticeMateTest do
  @moduledoc """
  Testing will be outside in for this application. I want to make sure in broad terms that functionality
  works and move forward as needed. As the application grows namespaces i.e. spotify or token store 
  should likely be unit tested exhaustively, but for now that seems like a misuse of effort.
  """
  use PracticeMate.DataCase

  alias PracticeMate.TokenStore.{Registry, Bucket}
  alias PracticeMate.Spotify

  setup do
    Registry.create(Registry, Spotify)
    :ok
  end

  describe "save_authorization/1" do
    test "saves a token from a successful authorization" do
      PracticeMate.save_authorization("goodcode")
      {:ok, pid} = Registry.lookup(Registry, Spotify)

      # Assert that the token has been cached in the appropriate bucket
      assert "goodtoken" == Bucket.get(pid, :token)
    end
  end

  describe "select_song/0" do
    defmodule GoodIOModule do
      def gets(_string), do: "1\n"
      def puts(_string), do: :ok
    end

    test "Good input will set a song to playing, and store the active song in cache" do
      assert :ok = PracticeMate.select_song(GoodIOModule)
      {:ok, pid} = Registry.lookup(Registry, Spotify)

      assert %{
               name: "Welcome to Miami",
               artist: "Will Smith",
               id: "390484auadfmkls"
             } = Bucket.get(pid, :active_song)
    end

    defmodule BadIOModule do
      def gets(_string), do: "6\n"
      def puts(_string), do: :ok
    end

    test "Bad input will return error and exit" do
      assert {:error, :invalid_selection} = PracticeMate.select_song(BadIOModule)
    end
  end
end
