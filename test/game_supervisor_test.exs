defmodule GameSupervisorTest do
  use ExUnit.Case, async: true

  alias Pinochle.GameSupervisor

  test "Start two games in the GameSupervisor" do
    GameSupervisor.start_game("Bill's Game")
    GameSupervisor.start_game("Michael's Game")

    assert DynamicSupervisor.count_children(GameSupervisor) == %{
             active: 2,
             specs: 2,
             supervisors: 0,
             workers: 2
           }
  end

  test "Stop a game and see that it is no longer in the supervisor" do
    name = "Hopefully Pinochle"
    GameSupervisor.start_game(name)
    GameSupervisor.stop_game(name)

    assert DynamicSupervisor.count_children(GameSupervisor) == %{
             active: 0,
             specs: 0,
             supervisors: 0,
             workers: 0
           }
  end
end
