defmodule CardTest do
  use ExUnit.Case

  import Pinochle.Card

  test "Create a card" do
    assert new(:queen, :spades) == %Pinochle.Card{rank: :queen, suit: :spades}
  end
end
