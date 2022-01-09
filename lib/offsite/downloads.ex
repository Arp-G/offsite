defmodule Offsite.Downloads do
  @moduledoc """
  The Downloads context.
  """

  @doc """
  Returns the list of downloads.
  """
  def list_downloads do
    Offsite.Downloaders.Direct.list()
  end

  @doc """
  Creates a download.
  """
  def create_download(src_url) do
    Offsite.Downloaders.Direct.add(src_url)
  end

  @doc """
  Deletes a download.
  """
  def delete_download(id) do
    Offsite.Downloaders.Direct.remove(id)
  end
end
