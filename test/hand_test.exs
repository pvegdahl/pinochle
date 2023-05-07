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

    assert remove_card(hand, Pinochle.Card.new(:nine, :clubs)) == [
             Pinochle.Card.new(:queen, :spades),
             Pinochle.Card.new(:jack, :diamonds)
           ]
  end

  test "Remove multiple cards" do
    hand = [Pinochle.Card.new(:queen, :spades), Pinochle.Card.new(:nine, :clubs), Pinochle.Card.new(:jack, :diamonds)]

    assert remove_cards(hand, [Pinochle.Card.new(:queen, :spades), Pinochle.Card.new(:jack, :diamonds)]) == [
             Pinochle.Card.new(:nine, :clubs)
           ]
  end

  test "Add cards to hand" do
    hand = [Pinochle.Card.new(:ace, :spades), Pinochle.Card.new(:ten, :spades), Pinochle.Card.new(:king, :spades)]

    # Sort the cards in the hands, because order is unspecified for the add_cards method
    assert Enum.sort(add_cards(hand, [Pinochle.Card.new(:queen, :spades), Pinochle.Card.new(:jack, :spades)])) ==
             Enum.sort(run_in_spades())
  end

  defp run_in_spades() do
    [
      Pinochle.Card.new(:ace, :spades),
      Pinochle.Card.new(:ten, :spades),
      Pinochle.Card.new(:king, :spades),
      Pinochle.Card.new(:queen, :spades),
      Pinochle.Card.new(:jack, :spades)
    ]
  end

  # Playable cards:
  #   - Must match suit if possible
  #   - Must beat current winner if possible
  #   - If can't match suit, must play trump if it wins
  #   - Otherwise, you can play anything
  test "All in suit cards are playable if ace is winning" do
    assert playable(run_in_spades(), Pinochle.Card.new(:ace, :spades), :spades, :diamonds) == run_in_spades()
  end

  test "All in suit cards higher than winning card are playable" do
    assert playable(run_in_spades(), Pinochle.Card.new(:king, :spades), :spades, :diamonds) |> Enum.sort() ==
             [Pinochle.Card.new(:ten, :spades), Pinochle.Card.new(:ace, :spades)] |> Enum.sort()
  end

  test "Only trump is playable if you have some and can't match suit" do
    hand = [
      Pinochle.Card.new(:ace, :spades),
      Pinochle.Card.new(:jack, :spades),
      Pinochle.Card.new(:ten, :hearts),
      Pinochle.Card.new(:king, :clubs)
    ]

    assert playable(hand, Pinochle.Card.new(:nine, :diamonds), :diamonds, :spades) |> Enum.sort() ==
             [Pinochle.Card.new(:ace, :spades), Pinochle.Card.new(:jack, :spades)] |> Enum.sort()
  end

  test "Must match the led suit if possible, even if trump is winning" do
    hand = [
      Pinochle.Card.new(:ace, :spades),
      Pinochle.Card.new(:jack, :spades),
      Pinochle.Card.new(:ten, :hearts),
    ]

    winning_card = Pinochle.Card.new(:nine, :hearts)
    led_suit = :spades
    trump = :hearts

    assert playable(hand, winning_card, led_suit, trump) |> Enum.sort() ==
             [Pinochle.Card.new(:ace, :spades), Pinochle.Card.new(:jack, :spades)] |> Enum.sort()
  end
end

# TODO
# Must match the led suit if possible, even if trump is winning
# If possible to play a winning trump, you must
# If you can't match suit and can't win with trump, then anything goes

