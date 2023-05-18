defmodule GameTest do
  use ExUnit.Case

  alias Pinochle.Game, as: Game
  alias Pinochle.Card, as: Card

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

  test "Player 3 playing a card wraps back to player 0" do
    game = sorted_game(3) |> Game.play_card(Card.new(:king, :spades))

    assert Game.current_player(game) == 0
  end

  defp sorted_game(starting_player) do
    # Each player will have all cards of one suit: clubs, diamonds, hearts, spades
    hands =
      Card.deck()
      |> Enum.sort_by(fn card -> card.suit end)
      |> Enum.chunk_every(12)

    %Game{current_player: starting_player, hands: hands}
  end
end
