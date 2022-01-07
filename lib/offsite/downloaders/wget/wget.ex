defmodule Offsite.Downloaders.Wget do
  @moduledoc """
  GenServer which stores aggregates and stores state for all wget worker processes
  Exposes APIs to add, delete, list wget downloads.

  Examples:

  {:ok, id} = Offsite.Downloaders.Wget.add("https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4", "/tmp/temp_video.vid")
  Offsite.Downloaders.Wget.status(id)
  Offsite.Downloaders.Wget.remove(id)
  Offsite.Downloaders.Wget.list
  """
  use GenServer
  import ShorterMaps
  alias Offsite.Downloaders.{Downloader, Download, Wget.Supervisor}

  require Logger

  @update_interval 1000
  @behaviour Downloader

  # Public Api

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @impl Downloader
  def add(src, dest), do: GenServer.call(__MODULE__, {:add, src, dest})

  @impl Downloader
  def remove(id), do: GenServer.call(__MODULE__, {:remove, id})

  @impl Downloader
  def status(id), do: GenServer.call(__MODULE__, {:status, id})

  @impl Downloader
  def list(), do: GenServer.call(__MODULE__, :list)

  # Callbacks

  @impl GenServer
  def init(_args) do
    Logger.info("Wget Server started")
    Process.send_after(self(), :fetch_all, @update_interval)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:status, id}, _from, state) do
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
  def handle_call({:add, src, dest}, _from, state) do
    id = UUID.uuid1()

    # Using start instead of start_link to avoid this parent process from getting terminated when worker terminates
    pid = Offsite.Downloaders.Wget.Supervisor.add(~M{id, src, dest, from: self()})

    {
      :reply,
      {:ok, id},
      Map.put(
        state,
        id,
        ~M{%Download id, pid, src, dest, name: guess_filename(src), type: :normal}
      )
    }
  end

  @impl GenServer
  def handle_call({:remove, id}, _from, state) do
    case Map.get(state, id) do
      ~M{%Download pid, dest} ->
        Supervisor.remove(pid)
        res = File.rm(dest)
        Logger.info("Remove left over file: #{inspect(res)}")

        {
          :reply,
          {:ok, id},
          Map.delete(state, id)
        }

      _ ->
        {
          :reply,
          {:error, :not_found},
          state
        }
    end
  end

  @impl GenServer
  def handle_call(:list, _from, state), do: {:reply, state, state}

  @impl GenServer
  def handle_info({:terminating, id, last_child_state}, state) do
    Logger.info("EXISTING STATE: #{inspect(state)}")

    {_old_value, state} =
      Map.get_and_update(state, id, fn
        current_value when is_nil(current_value) -> :pop
        current_value -> {current_value, merge_with_old_state(current_value, last_child_state)}
      end)

    Logger.info("UPDATED STATE: #{inspect(state)}")

    Logger.info("Recieved last state from child: #{id}, new_state: #{inspect(state)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:fetch_all, state) do
    new_state =
      state
      |> Enum.map(fn
        {id, ~M{%Download status} = download} when status in ~w(finish error cancel)a ->
          {id, download}

        {id, ~M{%Download pid} = download} ->
          {id, fetch_status(pid, download)}
      end)
      |> Enum.into(%{})

    Process.send_after(self(), :fetch_all, @update_interval)
    {:noreply, new_state}
  end

  # Private helpers

  defp fetch_status(pid, download) do
    if Process.alive?(pid) do
      new_download_state = GenServer.call(pid, :status)
      merge_with_old_state(download, new_download_state)
    else
      ~M{%Download download|status: :error, message: "Killed"}
    end
  end

  defp merge_with_old_state(
         old_download,
         ~M{size, status, progress, bytes_downloaded, error_reason}
       ) do
    ~M{%Download old_download|size, status, progress, bytes_downloaded, message: error_reason}
  end

  defp guess_filename(url) do
    url
    |> URI.parse()
    |> Map.fetch!(:path)
    |> Path.basename()
    |> String.trim()
  end
end
