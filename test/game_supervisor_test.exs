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
end
