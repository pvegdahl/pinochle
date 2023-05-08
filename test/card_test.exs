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
    assert first_wins?(new(:ace, :clubs), new(:ace, :clubs), :spades)
  end

  test "First card loses if it is lower in the same suit" do
    assert !first_wins?(new(:king, :clubs), new(:ace, :clubs), :diamonds)
  end

  test "First card wins if it is higher in the same suit" do
    assert first_wins?(new(:king, :clubs), new(:jack, :clubs), :clubs)
  end

  test "First card wins if suits do not match" do
    assert first_wins?(new(:nine, :diamonds), new(:ten, :clubs), :hearts)
  end

  test "An off suit trump card wins" do
    assert !first_wins?(new(:ace, :spades), new(:nine, :hearts), :hearts)
  end

  test "Deck has 48 cards" do
    assert Enum.count(deck()) == 48
  end

  test "Deck has 2 each of 24 distinct cards" do
    card_frequencies = deck() |> Enum.frequencies()
    assert card_frequencies |> Enum.count() == 24
    assert card_frequencies |> Map.values() |> Enum.uniq() == [2]
  end
end
