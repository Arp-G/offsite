defmodule Offsite.Downloaders.Direct do
  @moduledoc """
  GenServer which stores aggregates and stores state for all download worker processes
  Exposes APIs to add, delete, list downloads.

  Examples:

  {:ok, id} = Offsite.Downloaders.Direct.add("https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4")
  Offsite.Downloaders.Direct.list()
  Offsite.Downloaders.Direct.get(id)
  Offsite.Downloaders.Direct.remove(id)
  """
  use GenServer
  import ShorterMaps
  alias Offsite.Downloaders.{Downloader, Download, Direct.Supervisor}

  require Logger

  @update_interval 1000
  @behaviour Downloader

  # Public Api

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @impl Downloader
  def add(src), do: GenServer.call(__MODULE__, {:add, src})

  @impl Downloader
  def remove(id), do: GenServer.call(__MODULE__, {:remove, id})

  @impl Downloader
  def get(id), do: GenServer.call(__MODULE__, {:get, id})

  @impl Downloader
  def list(), do: GenServer.call(__MODULE__, :list)

  # Callbacks

  @impl GenServer
  def init(_args) do
    Logger.info("Direct Server started")
    Process.send_after(self(), :fetch_all, @update_interval)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:get, id}, _from, state) do
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
    {id, dest} = Offsite.Helpers.get_download_destination()

    # Using start instead of start_link to avoid this parent process from getting terminated when worker terminates
    pid = Offsite.Downloaders.Direct.Supervisor.add(~M{id, src, dest, from: self()})

    {
      :reply,
      {:ok, id},
      Map.put(
        state,
        id,
        ~M{%Download id, pid, src, dest, name: guess_filename(src)}
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
    {_old_value, state} =
      Map.get_and_update(state, id, fn
        current_value when is_nil(current_value) -> :pop
        current_value -> {current_value, merge_with_old_state(current_value, last_child_state)}
      end)

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
         ~M{size, status, bytes_downloaded, start_time, end_time, error_reason}
       ) do
    ~M{%Download old_download|size, status, bytes_downloaded, start_time, end_time, message: error_reason}
  end

  defp guess_filename(url) do
    path =
      url
      |> URI.parse()
      |> Map.fetch!(:path)

    if(is_nil(path), do: UUID.uuid1(), else: path |> Path.basename() |> String.trim())
  end
end
