defmodule CardTest do
  use ExUnit.Case

  import Pinochle.Card

  test "Create a card" do
    assert new(:queen, :spades) == %Pinochle.Card{rank: :queen, suit: :spades}
  end

  test "Get all ranks" do
    assert ranks() == [:nine, :jack, :queen, :king, :ten, :ace]
  end

  test "Get all suits" do
    assert suits() == [:diamonds, :clubs, :hearts, :spades]
  end
end
