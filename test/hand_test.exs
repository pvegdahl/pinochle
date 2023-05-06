defmodule HandTest do
  use ExUnit.Case

  import Pinochle.Hand

  test "New hands is 4 hands" do
    assert deal() |> Enum.count() == 4
  end

  test "Each hand has 12 cards" do
    deal()
    |> Enum.each(fn hand -> assert Enum.count(hand) == 12 end)
  end

  test "The hands combined make up the deck" do
    sorted_hands = deal() |> Enum.concat() |> Enum.sort()
    sorted_deck = Pinochle.Card.deck() |> Enum.sort()

    assert sorted_hands == sorted_deck
  end

  test "The hands are randomized" do
    assert deal() != deal()
  end

  test "The hands are randomized even when sorted" do
    assert sort_hands(deal()) != sort_hands(deal())
  end

  defp sort_hands(hands) do
    hands
    |> Enum.map(&Enum.sort/1)
    |> Enum.sort()
  end

  test "Remove a card from the hand" do
    hand = [Pinochle.Card.new(:queen, :spades), Pinochle.Card.new(:nine, :clubs), Pinochle.Card.new(:jack, :diamonds)]

    assert remove(hand, Pinochle.Card.new(:nine, :clubs)) == [
             Pinochle.Card.new(:queen, :spades),
             Pinochle.Card.new(:jack, :diamonds)
           ]
  end

  test "Remove multiple cards" do
    hand = [Pinochle.Card.new(:queen, :spades), Pinochle.Card.new(:nine, :clubs), Pinochle.Card.new(:jack, :diamonds)]

    assert remove_multiple(hand, [Pinochle.Card.new(:queen, :spades), Pinochle.Card.new(:jack, :diamonds)]) == [
             Pinochle.Card.new(:nine, :clubs)
           ]
  end

  test "Add cards to hand" do
    hand = [Pinochle.Card.new(:ace, :spades), Pinochle.Card.new(:ten, :spades), Pinochle.Card.new(:king, :spades)]

    # Sort the cards in the hands, because order is unspecified for the add_cards method
    assert Enum.sort(add_cards(hand, [Pinochle.Card.new(:queen, :spades), Pinochle.Card.new(:jack, :spades)])) ==
             Enum.sort([
               Pinochle.Card.new(:ace, :spades),
               Pinochle.Card.new(:ten, :spades),
               Pinochle.Card.new(:king, :spades),
               Pinochle.Card.new(:queen, :spades),
               Pinochle.Card.new(:jack, :spades)
             ])
  end
end
