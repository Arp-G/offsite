defmodule Offsite.Downloaders.TorrentDownload do
  @moduledoc """
  A struct representing a download
  """

  use TypedStruct

  typedstruct do
    @typedoc "A download"

    field :id, String.t()
    field :hashId, String.t()
    field :name, String.t()
    field :magnetLink, String.t()
    field :dest, String.t()
    field :files, :list

    field :status,
          :initiate
          | :stopped
          | :check_wait
          | :check
          | :download_wait
          | :download
          | :seed_wait
          | :seed
          | :isolated,
          default: :initiate

    field :size, non_neg_integer(), default: 0
    field :percentDone, String.t()
    field :rateDownload, String.t()
    field :rateUpload, String.t()
    field :eta, String.t()
    field :bytes_downloaded, non_neg_integer(), default: 0
    field :start_time, DateTime.t()
  end
end
