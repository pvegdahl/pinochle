defmodule GameTest do
  use ExUnit.Case

  alias Pinochle.Game

  test "A new game is in the trick taking state" do
    {:ok, game} = Game.start_link()
    assert Game.get(game).game_state == :trick_taking
  end

  #  test "A new game process has state" do
  #  end
end
