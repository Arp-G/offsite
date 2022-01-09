defmodule Offsite.Helpers do
  @moduledoc """
  Helpers
  """
  @base_download_path "/tmp/"

  def get_download_destination do
    id = UUID.uuid1()

    {id, "/tmp/#{id}"}
  end
end
