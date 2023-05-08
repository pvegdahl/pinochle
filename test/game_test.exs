defmodule GameTest do
  use ExUnit.Case

  alias Pinochle.Game, as: Game

  test "New game has current player" do
    0..3 |> Enum.each(fn n -> assert Game.new(n) |> Game.current_player() == n end)
  end
end
