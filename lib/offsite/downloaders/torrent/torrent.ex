defmodule Offsite.Downloaders.Torrent do
  @moduledoc """
  GenServer which stores aggregates and stores state for all active torrents
  Exposes APIs to add, delete, list torrent downloads.

  Examples:

  {:ok, id} = Offsite.Downloaders.Torrent.add("magnet:?xt=urn:btih:829303A22C21681964EA39010B82A6B09F3BC84F&dn=The+Night+House+%282020%29+%5B720p%5D+%5BYTS.MX%5D&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.ch%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.cyberia.is%3A6969%2Fannounce&tr=http%3A%2F%2Fp4p.arenabg.com%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337%2Fannounce")
  Offsite.Downloaders.Torrent.list()
  Offsite.Downloaders.Torrent.get(id)
  Offsite.Downloaders.Torrent.remove(id)
  """
  use GenServer
  import ShorterMaps
  alias Offsite.Downloaders.{Downloader, TorrentDownload}

  require Logger

  @update_interval 3000
  @behaviour Downloader
  @script_path "./lib/offsite/downloaders/torrent/transmission.js"
  @base_dest "/tmp/torrents"

  # Public Api

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @impl Downloader
  def add(magnetLink), do: GenServer.call(__MODULE__, {:add, magnetLink})

  @impl Downloader
  def remove(id), do: GenServer.call(__MODULE__, {:remove, id})

  @impl Downloader
  def get(id), do: GenServer.call(__MODULE__, {:get, id})

  @impl Downloader
  def list(), do: GenServer.call(__MODULE__, :list)

  # Callbacks

  @impl GenServer
  def init(_args) do
    Logger.info("Torrent Server started")
    Process.send_after(self(), :fetch_all, @update_interval)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:get, id}, _from, state) do
    id = inspect(id)
    case Map.get(state, id) do
      nil ->
        {
          :reply,
          {:error, :not_found},
          state
        }

      download ->
        {
          :reply,
          {:ok, download},
          state
        }
    end
  end

  @impl GenServer
  def handle_call({:add, src}, _from, state) do
    payload =
      Jason.encode!(%{
        magnetUri: src,
        path: @base_dest
      })

    {resp, 0} = System.shell("#{@script_path} --method=ADD --payload='#{payload}'", into: "")
    Logger.info(resp)

    case Jason.decode!(resp) do
      %{"success" => true, "result" => id} ->
        {
          :reply,
          {:ok, id},
          Map.put(state, id, %TorrentDownload{id: id})
        }

      %{"success" => false, "reason" => reason} ->
        Logger.warn("Failed to add torrent due to error: #{reason}")
        {:reply, {:error, reason}, state}
    end
  end

  @impl GenServer
  def handle_call({:remove, id}, _from, state) do
    id = inspect(id)
    case Map.get(state, id) do
      ~M{%TorrentDownload hashId} ->
        payload = Jason.encode!(~m{id: hashId})

        {resp, 0} =
          System.shell("#{@script_path} --method=REMOVE --payload='#{payload}'", into: "")

        # Logger.info(resp)

        case Jason.decode!(resp) do
          %{"success" => true} ->
            {
              :reply,
              {:ok, :removed},
              Map.delete(state, id)
            }

          %{"success" => false, "reason" => reason} ->
            Logger.warn("Failed to remove torrent due to error: #{reason}")
            {:reply, {:error, reason}, state}
        end

      _ ->
        {:reply, {:error, :not_found}, state}
    end
  end

  @impl GenServer
  def handle_call(:list, _from, state), do: {:reply, state, state}

  @impl GenServer
  def handle_info(:fetch_all, state) do
    {resp, 0} = System.shell("#{@script_path} --method=LIST", into: "")
    # Logger.info(inspect(resp))

    new_state =
      case Jason.decode!(resp) do
        %{"success" => true, "result" => result} ->
          result
          |> Enum.map(fn {
                           id,
                           %{
                             "downloadDir" => downloadDir,
                             "files" => files,
                             "hashString" => hashString,
                             "magnetLink" => magnetLink,
                             "name" => name,
                             "percentDone" => percentDone,
                             "rateDownload" => rateDownload,
                             "rateUpload" => rateUpload,
                             "status" => status,
                             "sizeWhenDone" => sizeWhenDone,
                             "desiredAvailable" => desiredAvailable,
                             "eta" => eta
                           }
                         } ->
            {
              id,
              ~M{%TorrentDownload 
                id, 
                name,
                hashId: hashString, 
                percentDone,
                rateDownload,
                rateUpload,
                status: get_status(status),
                files, 
                magnetLink, 
                dest: downloadDir, 
                size: sizeWhenDone, 
                eta,
                bytes_downloaded: desiredAvailable 
              }
            }
          end)
          |> Map.new()

        %{"success" => false, "reason" => reason} ->
          Logger.warn("Failed to fetch torrents due to error: #{reason}")
          state
      end

    Process.send_after(self(), :fetch_all, @update_interval)
    {:noreply, new_state}
  end

  defp get_status(status) do
    case status do
      0 -> :stopped
      1 -> :check_wait
      2 -> :check
      3 -> :download_wait
      4 -> :download
      5 -> :seed_wait
      6 -> :seed
      7 -> :isolated
      _ -> :initiate
    end
  end
end
