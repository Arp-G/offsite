defmodule Offsite.Helpers do
  @moduledoc """
  Helpers
  """
  @base_download_path "/tmp"

  def get_download_destination do
    id = UUID.uuid1()

    {id, "#{@base_download_path}/#{id}"}
  end

  def to_int(num) when is_binary(num) do
    case Integer.parse(num) do
      {num, _} -> num
      :error -> 0
    end
  end

  def to_int(num), do: num

  def playable_extention(filepath) do
    # Usually browsers are only able to play ["mp4", "ogg", "webm"] files but
    # I was able to play other as well so removing this for now
    ext =
      Path.extname(filepath)
      |> String.trim_leading(".")
      |> String.downcase()
      |> String.trim()

    # if ext in ["mp4", "ogg", "webm"], do: ext, else: false

    ext
  end
end
