defmodule HandTest do
  use ExUnit.Case

  alias Pinochle.Card, as: Card
  alias Pinochle.Hand, as: Hand

  test "New hands is 4 hands" do
    assert Hand.deal() |> Enum.count() == 4
  end

  test "Each hand has 12 cards" do
    Hand.deal()
    |> Enum.each(fn hand -> assert Enum.count(hand) == 12 end)
  end

  test "The hands combined make up the deck" do
    sorted_hands = Hand.deal() |> Enum.concat() |> Enum.sort()
    sorted_deck = Card.deck() |> Enum.sort()

    assert sorted_hands == sorted_deck
  end

  test "The hands are randomized" do
    assert Hand.deal() != Hand.deal()
  end

  test "The hands are randomized even when sorted" do
    assert sort_hands(Hand.deal()) != sort_hands(Hand.deal())
  end

  defp sort_hands(hands) do
    hands
    |> Enum.map(&Enum.sort/1)
    |> Enum.sort()
  end

  test "Remove a card from the hand" do
    hand = [Card.new(:queen, :spades), Card.new(:nine, :clubs), Card.new(:jack, :diamonds)]

    assert Hand.remove_card(hand, Card.new(:nine, :clubs)) == [
             Card.new(:queen, :spades),
             Card.new(:jack, :diamonds)
           ]
  end

  test "Remove multiple cards" do
    hand = [Card.new(:queen, :spades), Card.new(:nine, :clubs), Card.new(:jack, :diamonds)]

    assert Hand.remove_cards(hand, [Card.new(:queen, :spades), Card.new(:jack, :diamonds)]) == [
             Card.new(:nine, :clubs)
           ]
  end

  test "Add cards to hand" do
    hand = [Card.new(:ace, :spades), Card.new(:ten, :spades), Card.new(:king, :spades)]

    # Sort the cards in the hands, because order is unspecified for the add_cards method
    assert Enum.sort(Hand.add_cards(hand, [Card.new(:queen, :spades), Card.new(:jack, :spades)])) ==
             Enum.sort(run_in_spades())
  end

  defp run_in_spades() do
    [
      Card.new(:ace, :spades),
      Card.new(:ten, :spades),
      Card.new(:king, :spades),
      Card.new(:queen, :spades),
      Card.new(:jack, :spades)
    ]
  end

  # Playable cards:
  #   - Must match suit if possible
  #   - Must beat current winner if possible
  #   - If can't match suit, must play trump if it wins
  #   - Otherwise, you can play anything
  test "All in suit cards are playable if ace is winning" do
    assert Hand.playable(run_in_spades(), Card.new(:ace, :spades), :spades, :diamonds) == run_in_spades()
  end

  test "All in suit cards higher than winning card are playable" do
    assert Hand.playable(run_in_spades(), Card.new(:king, :spades), :spades, :diamonds) |> Enum.sort() ==
             [Card.new(:ten, :spades), Card.new(:ace, :spades)] |> Enum.sort()
  end

  test "Only trump is playable if you have some and can't match suit" do
    hand = [
      Card.new(:ace, :spades),
      Card.new(:jack, :spades),
      Card.new(:ten, :hearts),
      Card.new(:king, :clubs)
    ]

    assert Hand.playable(hand, Card.new(:nine, :diamonds), :diamonds, :spades) |> Enum.sort() ==
             [Card.new(:ace, :spades), Card.new(:jack, :spades)] |> Enum.sort()
  end

  test "Must match the led suit if possible, even if trump is winning" do
    hand = [
      Card.new(:ace, :spades),
      Card.new(:jack, :spades),
      Card.new(:ten, :hearts)
    ]

    winning_card = Card.new(:nine, :hearts)
    led_suit = :spades
    trump = :hearts

    assert Hand.playable(hand, winning_card, led_suit, trump) |> Enum.sort() ==
             [Card.new(:ace, :spades), Card.new(:jack, :spades)] |> Enum.sort()
  end

  test "Must play a winning trump if possible" do
    hand = [
      Card.new(:ace, :spades),
      Card.new(:jack, :spades),
      Card.new(:ten, :hearts)
    ]

    winning_card = Card.new(:queen, :spades)
    led_suit = :clubs
    trump = :spades

    assert Hand.playable(hand, winning_card, led_suit, trump) == [Card.new(:ace, :spades)]
  end

  test "Anything goes when you can't match suit and can't win with trump" do
    hand = [
      Card.new(:queen, :spades),
      Card.new(:jack, :diamonds),
      Card.new(:ten, :hearts)
    ]

    winning_card = Card.new(:king, :spades)
    led_suit = :clubs
    trump = :spades

    assert Hand.playable(hand, winning_card, led_suit, trump) == hand
  end
end
