defmodule Offsite.Downloaders.Downloader do
  @moduledoc """
  A Downloader behaviour that should be implemented by all downloaders
  """

  @doc """
  Add a download
  """
  @callback add(String.t()) :: {:ok, String.t()} | {:error, String.t()}

  @doc """
  Remove or cancel a download
  """
  @callback remove(String.t()) :: {:ok, String.t()} | {:error, String.t()}

  @doc """
  Get the download struct for given id
  """
  @callback get(String.t()) :: {:ok, Download.t()} | {:error, String.t()}

  @doc """
  Get all download status
  """
  @callback list() :: {:ok, [Download.t()]}
end
