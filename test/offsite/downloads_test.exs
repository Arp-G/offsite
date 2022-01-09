defmodule Offsite.DownloadsTest do
  use Offsite.DataCase

  alias Offsite.Downloads

  describe "downloads" do
    alias Offsite.Downloads.Download

    import Offsite.DownloadsFixtures

    @invalid_attrs %{}

    test "list_downloads/0 returns all downloads" do
      download = download_fixture()
      assert Downloads.list_downloads() == [download]
    end

    test "get_download!/1 returns the download with given id" do
      download = download_fixture()
      assert Downloads.get_download!(download.id) == download
    end

    test "create_download/1 with valid data creates a download" do
      valid_attrs = %{}

      assert {:ok, %Download{} = download} = Downloads.create_download(valid_attrs)
    end

    test "create_download/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Downloads.create_download(@invalid_attrs)
    end

    test "update_download/2 with valid data updates the download" do
      download = download_fixture()
      update_attrs = %{}

      assert {:ok, %Download{} = download} = Downloads.update_download(download, update_attrs)
    end

    test "update_download/2 with invalid data returns error changeset" do
      download = download_fixture()
      assert {:error, %Ecto.Changeset{}} = Downloads.update_download(download, @invalid_attrs)
      assert download == Downloads.get_download!(download.id)
    end

    test "delete_download/1 deletes the download" do
      download = download_fixture()
      assert {:ok, %Download{}} = Downloads.delete_download(download)
      assert_raise Ecto.NoResultsError, fn -> Downloads.get_download!(download.id) end
    end

    test "change_download/1 returns a download changeset" do
      download = download_fixture()
      assert %Ecto.Changeset{} = Downloads.change_download(download)
    end
  end
end
