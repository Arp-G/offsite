defmodule Offsite.Helpers do
  @moduledoc """
  Helpers
  """
  @base_download_path "/tmp/"

  def get_download_destination do
    id = UUID.uuid1()

    {id, "/tmp/#{id}"}
  end

  def to_int(num) when is_binary(num) do
    case Integer.parse(num) do
      {num, _} -> num
      :error -> 0
    end
  end

  def to_int(num), do: num
end
