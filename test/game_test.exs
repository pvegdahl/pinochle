defmodule GameTest do
  use ExUnit.Case

  alias Pinochle.Game

  test "A new game is in the trick taking state" do
    assert Game.new().state == :trick_taking
  end
end