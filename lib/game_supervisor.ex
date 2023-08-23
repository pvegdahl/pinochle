defmodule Pinochle.GameSupervisor do
  use DynamicSupervisor

  alias Pinochle.Game

  def start_link(_), do: DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_game(name), do: DynamicSupervisor.start_child(__MODULE__, make_child_spec(name))

  defp make_child_spec(name) do
    %{id: Game, start: {Game, :start_link, [name]}}
  end

  def stop_game(name) do
    DynamicSupervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

  defp pid_from_name(name) do
    name
    |> Game.via_tuple()
    |> GenServer.whereis()
  end
end
