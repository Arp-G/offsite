defmodule Offsite.Downloaders.Wget.Supervisor do
  use DynamicSupervisor
  require Logger

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add(args) do
    {:ok, pid} =
      DynamicSupervisor.start_child(__MODULE__, {Offsite.Downloaders.Wget.Worker, args})

    pid
  end

  def remove(child_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, child_pid)
  end
end
