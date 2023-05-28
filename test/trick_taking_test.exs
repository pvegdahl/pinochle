defmodule TrickTakingTest do
  use ExUnit.Case

  alias Pinochle.{TrickTaking, Card, Trick}

  test "A new game has current player" do
    0..3 |> Enum.each(fn n -> assert TrickTaking.new(n, :hearts) |> TrickTaking.current_player() == n end)
  end

  test "A new game has a 12 card hand for each player" do
    game = TrickTaking.new(0, :hearts)
    0..3 |> Enum.each(fn n -> assert TrickTaking.hand(game, n) |> Enum.count() == 12 end)
  end

  test "A player playing a card increments to the next player" do
    {:ok, game} = sorted_game(0) |> TrickTaking.play_card(0, Card.new(:queen, :clubs))

    assert TrickTaking.current_player(game) == 1
  end

  defp sorted_game(starting_player, trump \\ :clubs) do
    # Each player will have all cards of one suit: clubs, diamonds, hearts, spades
    hands =
      Card.deck()
      |> Enum.sort_by(fn card -> card.suit end)
      |> Enum.chunk_every(12)

    %TrickTaking{starting_player: starting_player, hands: hands, trump: trump}
  end

  test "Player 3 playing a card wraps back to player 0" do
    {:ok, game} = sorted_game(3) |> TrickTaking.play_card(3, Card.new(:king, :spades))

    assert TrickTaking.current_player(game) == 0
  end

  test "A player playing a card removes it from their hand" do
    {:ok, game} = sorted_game(0) |> TrickTaking.play_card(0, Card.new(:queen, :clubs))

    assert TrickTaking.hand(game, 0) |> Enum.sort() ==
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

    game = %TrickTaking{starting_player: 2, hands: hands, trump: :diamonds}

    {:ok, updated_game} = TrickTaking.play_card(game, 2, Card.new(:jack, :diamonds))

    assert TrickTaking.hand(updated_game, 0) == [Card.new(:jack, :diamonds)]
    assert TrickTaking.hand(updated_game, 1) == [Card.new(:jack, :diamonds)]
    assert TrickTaking.hand(updated_game, 2) == []
    assert TrickTaking.hand(updated_game, 3) == [Card.new(:jack, :diamonds)]
  end

  test "A new game does not have a current trick" do
    assert TrickTaking.new(0, :hearts) |> TrickTaking.current_trick() == nil
  end

  test "Playing the first card of the game creates a new trick" do
    game = sorted_game(3)

    {:ok, updated_game} = TrickTaking.play_card(game, 3, Card.new(:nine, :spades))

    assert TrickTaking.current_trick(updated_game) == Trick.new(3, Card.new(:nine, :spades))
  end

  test "Playing another card updates the existing trick" do
    {:ok, game} = sorted_game(3) |> TrickTaking.play_card(3, Card.new(:nine, :spades))

    {:ok, updated_game} = TrickTaking.play_card(game, 0, Card.new(:ten, :clubs))

    trick_cards =
      updated_game
      |> TrickTaking.current_trick()
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

    assert TrickTaking.current_player(game) == 3
  end

  defp play_card_helper(game, card) do
    current_player = TrickTaking.current_player(game)
    {:ok, updated_game} = TrickTaking.play_card(game, current_player, card)
    updated_game
  end

  test "A new trick replaces the last trick" do
    game =
      sorted_game(0, :spades)
      |> play_card_helper(Card.new(:ace, :clubs))
      |> play_card_helper(Card.new(:nine, :diamonds))
      |> play_card_helper(Card.new(:nine, :hearts))
      |> play_card_helper(Card.new(:nine, :spades))
      |> play_card_helper(Card.new(:ace, :spades))

    trick_cards =
      game
      |> TrickTaking.current_trick()
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

    game = %TrickTaking{
      starting_player: 0,
      hands: hands,
      tricks: [Trick.new(0, Card.new(:ten, :spades))],
      trump: :spades
    }

    assert TrickTaking.play_card(game, 1, Card.new(:jack, :spades)) == {:error, :invalid_card}
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

    game = %TrickTaking{starting_player: 0, hands: hands, tricks: [trick], trump: :spades}

    assert TrickTaking.play_card(game, 0, Card.new(:jack, :spades)) |> elem(0) == :ok
  end

  test "Okay, a card not in hand is not playable even on a fresh game" do
    game = sorted_game(0)

    assert TrickTaking.play_card(game, 0, Card.new(:king, :hearts)) == {:error, :invalid_card}
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

    game = %TrickTaking{starting_player: 0, hands: hands, tricks: [trick], trump: :spades}

    assert TrickTaking.play_card(game, 0, Card.new(:king, :hearts)) == {:error, :invalid_card}
  end

  test "A non-active player cannot play a card" do
    game = sorted_game(0)

    assert TrickTaking.play_card(game, 1, Card.new(:king, :diamonds)) == {:error, :inactive_player}
    assert TrickTaking.play_card(game, 2, Card.new(:king, :hearts)) == {:error, :inactive_player}
    assert TrickTaking.play_card(game, 3, Card.new(:king, :spades)) == {:error, :inactive_player}
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

    game = %TrickTaking{starting_player: 0, tricks: tricks, hands: [[], [], [], []], trump: :spades}

    assert TrickTaking.score_tricks(game) == %{0 => 5, 1 => 0, 2 => 0, 3 => 4}
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

    game = %TrickTaking{starting_player: 0, tricks: tricks, hands: [[], [], [], []], trump: :spades}

    assert TrickTaking.score_tricks(game) == %{0 => 0, 1 => 0, 2 => 25, 3 => 0}
  end
end
