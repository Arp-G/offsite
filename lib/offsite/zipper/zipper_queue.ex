defmodule Offsite.Zipper.ZipperQueue do
  use GenServer

  def get_work() do
    GenServer.call(__MODULE__, :get_work)
  end

  def enqueue_work(work) do
    GenServer.cast(__MODULE__, {:enqueue_work, work})
  end

  def start_link(_opts), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  # Callbacks

  @impl true
  def init(_args) do
    {:ok, []}
  end

  @impl true
  def handle_call(:get_work, _from, [head | tail]), do: {:reply, head, tail}

  def handle_call(:get_work, _from, []), do: {:reply, :no_work, []}

  @impl true
  def handle_cast({:enqueue_work, work}, state), do: {:noreply, state ++ [work]}
end
