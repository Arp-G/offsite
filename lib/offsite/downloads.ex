defmodule Offsite.Downloads do
  @moduledoc """
  The Downloads context.
  """

  alias Offsite.Downloaders.Direct

  @doc """
  Returns the list of downloads.
  """
  def list_downloads do
    Direct.list()
  end

  def get_download(id) do
    Direct.get(id)
  end

  @doc """
  Creates a download.
  """
  def create_download(src_url) do
    Direct.add(src_url)
  end

  @doc """
  Deletes a download.
  """
  def delete_download(id) do
    Direct.remove(id)
  end
end
