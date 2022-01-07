defmodule Offsite.Downloaders.Download do
  @moduledoc """
  A struct representing a download
  """

  use TypedStruct

  typedstruct do
    @typedoc "A download"

    field :id, String.t()
    field :pid, pid()
    field :name, String.t()
    field :src, String.t()
    field :dest, String.t()
    field :type, :normal | :torrent
    field :status, :initiate | :active | :finish | :error | :cancel, default: :initiate
    field :size, non_neg_integer(), default: 0
    field :progress, non_neg_integer(), default: 0
    field :bytes_downloaded, non_neg_integer(), default: 0
    field :message, String.t()
  end
end
