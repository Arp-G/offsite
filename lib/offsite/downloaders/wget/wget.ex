defmodule Offsite.Downloaders.Wget do
  use GenServer
  import ShorterMaps
  alias Offsite.Downloaders.{Downloader, Download, Wget.Worker}

  @behaviour Downloader

  @impl Downloader
  def add(src, dest), do: GenServer.call(__MODULE__, {:add, src, dest})

  @impl Downloader
  def remove(id), do: GenServer.call(__MODULE__, {:remove, id})

  @impl Downloader
  def status(id), do: GenServer.call(__MODULE__, {:status, id})

  @impl Downloader
  def list() do
    # TODO
  end

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @impl GenServer
  def init(_args) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:status, id}, _from, state) do
    case Map.get(state, id) do
      ~M{%Download pid} ->

        {
          :reply,
          {:ok, GenServer.call(pid, :status)},
          state
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
  def handle_call({:add, src, dest}, _from, state) do
    download = ~M{%Download src, dest, type: :normal}
    id = download.id

    case Worker.start_link(~M{id, src, dest}) do
      {:ok, pid} ->
        {
          :reply,
          {:ok, id},
          Map.put(state, id, ~M{%Download id, pid, src, dest, type: :normal})
        }

      error ->
        {
          :reply,
          {:error, inspect(error)},
          state
        }
    end
  end

  @impl GenServer
  def handle_call({:remove, id}, _from, state) do
    case Map.get(state, id) do
      ~M{%Download pid} ->
        GenServer.cast(pid, :cancel)

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
end
