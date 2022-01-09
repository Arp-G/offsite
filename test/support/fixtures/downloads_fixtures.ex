defmodule Offsite.DownloadsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Offsite.Downloads` context.
  """

  @doc """
  Generate a download.
  """
  def download_fixture(attrs \\ %{}) do
    {:ok, download} =
      attrs
      |> Enum.into(%{})
      |> Offsite.Downloads.create_download()

    download
  end
end
