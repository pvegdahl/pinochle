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

  test "First card wins if they are the same" do
    assert wins?(new(:ace, :clubs), new(:ace, :clubs))
  end

  test "First card loses if it is lower in the same suit" do
    assert !wins?(new(:king, :clubs), new(:ace, :clubs))
  end

  test "First card wins if it is higher in the same suit" do
    assert wins?(new(:king, :clubs), new(:jack, :clubs))
  end

  test "First card wins if suits do not match" do
    assert wins?(new(:nine, :diamonds), new(:ten, :clubs))
  end
end
