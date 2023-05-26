defmodule GameTest do
  use ExUnit.Case

  alias Pinochle.Game, as: Game
  alias Pinochle.Card, as: Card
  alias Pinochle.Trick, as: Trick

  test "A new game has current player" do
    0..3 |> Enum.each(fn n -> assert Game.new(n, :hearts) |> Game.current_player() == n end)
  end

  test "A new game has a 12 card hand for each player" do
    game = Game.new(0, :hearts)
    0..3 |> Enum.each(fn n -> assert Game.hand(game, n) |> Enum.count() == 12 end)
  end

  test "A player playing a card increments to the next player" do
    {:ok, game} = sorted_game(0) |> Game.play_card(0, Card.new(:queen, :clubs))

    assert Game.current_player(game) == 1
  end

  defp sorted_game(starting_player, trump \\ :clubs) do
    # Each player will have all cards of one suit: clubs, diamonds, hearts, spades
    hands =
      Card.deck()
      |> Enum.sort_by(fn card -> card.suit end)
      |> Enum.chunk_every(12)

    %Game{starting_player: starting_player, hands: hands, trump: trump}
  end

  test "Player 3 playing a card wraps back to player 0" do
    {:ok, game} = sorted_game(3) |> Game.play_card(3, Card.new(:king, :spades))

    assert Game.current_player(game) == 0
  end

  test "A player playing a card removes it from their hand" do
    {:ok, game} = sorted_game(0) |> Game.play_card(0, Card.new(:queen, :clubs))

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

    game = %Game{starting_player: 2, hands: hands, trump: :diamonds}

    {:ok, updated_game} = Game.play_card(game, 2, Card.new(:jack, :diamonds))

    assert Game.hand(updated_game, 0) == [Card.new(:jack, :diamonds)]
    assert Game.hand(updated_game, 1) == [Card.new(:jack, :diamonds)]
    assert Game.hand(updated_game, 2) == []
    assert Game.hand(updated_game, 3) == [Card.new(:jack, :diamonds)]
  end

  test "A new game does not have a current trick" do
    assert Game.new(0, :hearts) |> Game.current_trick() == nil
  end

  test "Playing the first card of the game creates a new trick" do
    game = sorted_game(3)

    {:ok, updated_game} = Game.play_card(game, 3, Card.new(:nine, :spades))

    assert Game.current_trick(updated_game) == Trick.new(3, Card.new(:nine, :spades))
  end

  test "Playing another card updates the existing trick" do
    {:ok, game} = sorted_game(3) |> Game.play_card(3, Card.new(:nine, :spades))

    {:ok, updated_game} = Game.play_card(game, 0, Card.new(:ten, :clubs))

    trick_cards =
      updated_game
      |> Game.current_trick()
      |> Trick.cards()

    assert trick_cards == [Card.new(:nine, :spades), Card.new(:ten, :clubs)]
  end

  test "When a trick is done, then the next player is the player who one the trick" do
    game =
      sorted_game(0, :spades)
      |> play_card_helper(Card.new(:ace, :clubs))
      |> play_card_helper(Card.new(:nine, :diamonds))
      |> play_card_helper(Card.new(:nine, :hearts))
      |> play_card_helper(Card.new(:nine, :spades))

    assert Game.current_player(game) == 3
  end

  defp play_card_helper(game, card) do
    current_player = Game.current_player(game)
    {:ok, updated_game} = Game.play_card(game, current_player, card)
    updated_game
  end

  test "A new trick replaces the last trick" do
    game =
      sorted_game(0, :spades)
      |> play_card_helper(Card.new(:ace, :clubs))
      |> play_card_helper(Card.new(:nine, :diamonds))
      |> play_card_helper(Card.new(:nine, :hearts))
      |> play_card_helper(Card.new(:nine, :spades))

    {:ok, updated_game} = game |> Game.play_card(0, Card.new(:ace, :spades))

    trick_cards =
      updated_game
      |> Game.current_trick()
      |> Trick.cards()

    assert trick_cards == [Card.new(:ace, :spades)]
  end

  test "Don't allow playing an unplayable card" do
    hands = [
      [a_card()],
      [Card.new(:jack, :spades), Card.new(:ace, :spades)],
      [a_card(), a_card()],
      [a_card(), a_card()]
    ]

    game = %Game{starting_player: 0, hands: hands, tricks: [Trick.new(0, Card.new(:ten, :spades))], trump: :spades}

    assert Game.play_card(game, 1, Card.new(:jack, :spades)) == {:error, :invalid_card}
  end

  defp a_card(), do: Card.new(:queen, :hearts)

  test "Any card is playable on a new trick" do
    hands = [
      [Card.new(:jack, :spades), Card.new(:ace, :spades)],
      [a_card(), a_card()],
      [a_card(), a_card()],
      [a_card(), a_card()]
    ]

    trick =
      create_trick(0, [
        Card.new(:ten, :spades),
        Card.new(:nine, :spades),
        Card.new(:jack, :spades),
        Card.new(:queen, :spades)
      ])

    game = %Game{starting_player: 0, hands: hands, tricks: [trick], trump: :spades}

    assert Game.play_card(game, 0, Card.new(:jack, :spades)) |> elem(0) == :ok
  end

  test "Okay, a card not in hand is not playable even on a fresh game" do
    game = sorted_game(0)

    assert Game.play_card(game, 0, Card.new(:king, :hearts)) == {:error, :invalid_card}
  end

  test "A card not in hand is also not playable on a fresh trick" do
    hands = [
      [Card.new(:jack, :spades), Card.new(:ace, :spades)],
      [a_card(), a_card()],
      [a_card(), a_card()],
      [a_card(), a_card()]
    ]

    trick =
      create_trick(0, [
        Card.new(:ten, :spades),
        Card.new(:nine, :spades),
        Card.new(:jack, :spades),
        Card.new(:queen, :spades)
      ])

    game = %Game{starting_player: 0, hands: hands, tricks: [trick], trump: :spades}

    assert Game.play_card(game, 0, Card.new(:king, :hearts)) == {:error, :invalid_card}
  end

  defp create_trick(starting_player, [first_card | rest_of_cards]) do
    trick = Trick.new(starting_player, first_card)

    Enum.reduce(rest_of_cards, trick, fn card, acc -> Trick.play_card(acc, card) end)
  end

  test "Score all tricks and assign points" do
    tricks = [
      create_trick(3, [
        Card.new(:ace, :diamonds),
        Card.new(:nine, :spades),
        Card.new(:ten, :hearts),
        Card.new(:king, :hearts)
      ]),
      create_trick(3, [
        Card.new(:ace, :hearts),
        Card.new(:nine, :hearts),
        Card.new(:king, :hearts),
        Card.new(:queen, :hearts)
      ]),
      create_trick(0, [
        Card.new(:nine, :spades),
        Card.new(:queen, :spades),
        Card.new(:king, :spades),
        Card.new(:ten, :spades)
      ]),
      create_trick(0, [
        Card.new(:ten, :spades),
        Card.new(:nine, :spades),
        Card.new(:king, :spades),
        Card.new(:queen, :spades)
      ])
    ]

    game = %Game{starting_player: 0, tricks: tricks, hands: [[], [], [], []], trump: :spades}

    assert Game.score_tricks(game) == %{0 => 5, 1 => 0, 2 => 0, 3 => 4}
  end

  test "Add a point for last trick when scoring" do
    tricks =
      create_trick(2, [
        Card.new(:ace, :spades),
        Card.new(:nine, :spades),
        Card.new(:king, :spades),
        Card.new(:queen, :spades)
      ])
      |> List.duplicate(12)

    game = %Game{starting_player: 0, tricks: tricks, hands: [[], [], [], []], trump: :spades}

    assert Game.score_tricks(game) == %{0 => 0, 1 => 0, 2 => 25, 3 => 0}
  end
end

# TODO
# - Even on a fresh trick, you can only play cards in your hand
