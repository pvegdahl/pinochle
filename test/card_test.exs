defmodule CardTest do
  use ExUnit.Case

  alias Pinochle.Card, as: Card

  test "Create a card" do
    assert Card.new(:queen, :spades) == %Card{rank: :queen, suit: :spades}
  end

  test "Get all ranks" do
    assert Card.ranks() == [:nine, :jack, :queen, :king, :ten, :ace]
  end

  test "Get all suits" do
    assert Card.suits() == [:diamonds, :clubs, :hearts, :spades]
  end

  test "First card wins if they are the same" do
    assert Card.first_wins?(Card.new(:ace, :clubs), Card.new(:ace, :clubs), :spades)
  end

  test "First card loses if it is lower in the same suit" do
    assert !Card.first_wins?(Card.new(:king, :clubs), Card.new(:ace, :clubs), :diamonds)
  end

  test "First card wins if it is higher in the same suit" do
    assert Card.first_wins?(Card.new(:king, :clubs), Card.new(:jack, :clubs), :clubs)
  end

  test "First card wins if suits do not match" do
    assert Card.first_wins?(Card.new(:nine, :diamonds), Card.new(:ten, :clubs), :hearts)
  end

  test "An off suit trump card wins" do
    assert !Card.first_wins?(Card.new(:ace, :spades), Card.new(:nine, :hearts), :hearts)
  end

  test "Deck has 48 cards" do
    assert Enum.count(Card.deck()) == 48
  end

  test "Deck has 2 each of 24 distinct cards" do
    card_frequencies = Card.deck() |> Enum.frequencies()
    assert card_frequencies |> Enum.count() == 24
    assert card_frequencies |> Map.values() |> Enum.uniq() == [2]
  end
end
