defmodule GameTest do
  use ExUnit.Case

  alias Pinochle.Game, as: Game
  alias Pinochle.Card, as: Card
  alias Pinochle.Trick, as: Trick

  test "A new game has current player" do
    0..3 |> Enum.each(fn n -> assert Game.new(n) |> Game.current_player() == n end)
  end

  test "A new game has a 12 card hand for each player" do
    game = Game.new(0)
    0..3 |> Enum.each(fn n -> assert Game.hand(game, n) |> Enum.count() == 12 end)
  end

  test "A player playing a card increments to the next player" do
    game = sorted_game(0) |> Game.play_card(Card.new(:queen, :clubs))

    assert Game.current_player(game) == 1
  end

  defp sorted_game(starting_player) do
    # Each player will have all cards of one suit: clubs, diamonds, hearts, spades
    hands =
      Card.deck()
      |> Enum.sort_by(fn card -> card.suit end)
      |> Enum.chunk_every(12)

    %Game{current_player: starting_player, hands: hands}
  end

  test "Player 3 playing a card wraps back to player 0" do
    game = sorted_game(3) |> Game.play_card(Card.new(:king, :spades))

    assert Game.current_player(game) == 0
  end

  test "A player playing a card removes it from their hand" do
    game = sorted_game(0) |> Game.play_card(Card.new(:queen, :clubs))

    assert Game.hand(game, 0) |> Enum.sort() ==
             [
               Card.new(:nine, :clubs),
               Card.new(:nine, :clubs),
               Card.new(:jack, :clubs),
               Card.new(:jack, :clubs),
               Card.new(:queen, :clubs),
               Card.new(:king, :clubs),
               Card.new(:king, :clubs),
               Card.new(:ten, :clubs),
               Card.new(:ten, :clubs),
               Card.new(:ace, :clubs),
               Card.new(:ace, :clubs)
             ]
             |> Enum.sort()
  end

  test "A player playing a card removes it from their hand ONLY" do
    hands = [
      [Card.new(:jack, :diamonds)],
      [Card.new(:jack, :diamonds)],
      [Card.new(:jack, :diamonds)],
      [Card.new(:jack, :diamonds)]
    ]

    game = %Game{current_player: 2, hands: hands}

    updated_game = Game.play_card(game, Card.new(:jack, :diamonds))

    assert Game.hand(updated_game, 0) == [Card.new(:jack, :diamonds)]
    assert Game.hand(updated_game, 1) == [Card.new(:jack, :diamonds)]
    assert Game.hand(updated_game, 2) == []
    assert Game.hand(updated_game, 3) == [Card.new(:jack, :diamonds)]
  end

  test "A new game does not have a current trick" do
    assert Game.new(0) |> Game.current_trick() == nil
  end

  test "Playing the first card of the game creates a new trick" do
    game = sorted_game(3)

    updated_game = Game.play_card(game, Card.new(:nine, :spades))

    assert Game.current_trick(updated_game) == Trick.new(3, Card.new(:nine, :spades))
  end

  test "Playing another card updates the existing trick" do
    game = sorted_game(3) |> Game.play_card(Card.new(:nine, :spades))

    trick_cards =
      game
      |> Game.play_card(Card.new(:ten, :clubs))
      |> Game.current_trick()
      |> Trick.cards()

    assert trick_cards == [Card.new(:nine, :spades), Card.new(:ten, :clubs)]
  end
end

# TODO
# - play_card
#   + Update the trick
#     ~ End of trick
#   + Don't allow if the card isn't playable.
#   +
