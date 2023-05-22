defmodule TrickTest do
  use ExUnit.Case

  alias Pinochle.Card, as: Card
  alias Pinochle.Trick, as: Trick

  test "New tricks have a single card" do
    assert Trick.new(0, a_card()) |> Map.get(:cards) |> Enum.count() == 1
  end

  defp a_card(), do: Card.new(:jack, :diamonds)

  test "The current player for a new trick is the starting player + 1" do
    0..2 |> Enum.each(fn n -> assert Trick.new(n, a_card()) |> Trick.current_player() == n + 1 end)
  end

  test "The current player wraps from 3 to 0" do
    assert Trick.new(3, a_card()) |> Trick.current_player() == 0
  end

  test "Playing a card increments the current_player" do
    assert Trick.new(1, a_card()) |> play_n_cards(1) |> Trick.current_player() == 3
    assert Trick.new(0, a_card()) |> play_n_cards(2) |> Trick.current_player() == 3
  end

  defp play_n_cards(trick, 0), do: trick

  defp play_n_cards(trick, n) do
    trick
    |> Trick.play_card(a_card())
    |> play_n_cards(n - 1)
  end

  test "The current_player count wraps with more cards played" do
    assert Trick.new(2, a_card()) |> play_n_cards(2) |> Trick.current_player() == 1
  end

  test "Winning card is the only card" do
    assert Trick.new(0, a_card()) |> Trick.winning_card(:spades) == a_card()
  end

  test "First card wins if higher in same suit" do
    first = Card.new(:ten, :hearts)
    second = Card.new(:king, :hearts)
    assert Trick.new(0, first) |> Trick.play_card(second) |> Trick.winning_card(:spades) == first
  end

  test "Second card wins if higher in same suit" do
    first = Card.new(:king, :hearts)
    second = Card.new(:ten, :hearts)
    assert Trick.new(0, first) |> Trick.play_card(second) |> Trick.winning_card(:spades) == second
  end

  test "Only trump wins against others" do
    trick =
      Trick.new(0, Card.new(:king, :hearts))
      |> Trick.play_card(Card.new(:nine, :clubs))
      |> Trick.play_card(Card.new(:ten, :hearts))

    assert Trick.winning_card(trick, :clubs) == Card.new(:nine, :clubs)
  end

  test "Get winning player when first player wins" do
    0..3 |> Enum.each(&test_starting_player_wins/1)
  end

  defp test_starting_player_wins(starting_player) do
    trick =
      Trick.new(starting_player, Card.new(:ace, :hearts))
      |> Trick.play_card(Card.new(:jack, :hearts))
      |> Trick.play_card(Card.new(:queen, :hearts))
      |> Trick.play_card(Card.new(:king, :hearts))

    assert Trick.winning_player(trick, :clubs) == starting_player
  end

  test "Third player wins with wrap" do
    trick =
      Trick.new(3, Card.new(:ace, :hearts))
      |> Trick.play_card(Card.new(:jack, :hearts))
      |> Trick.play_card(Card.new(:queen, :clubs))
      |> Trick.play_card(Card.new(:king, :hearts))

    assert Trick.winning_player(trick, :clubs) == 1
  end

  test "First instance wins with multiple of the same winning card" do
    trick =
      Trick.new(2, Card.new(:nine, :spades))
      |> Trick.play_card(Card.new(:ace, :spades))
      |> Trick.play_card(Card.new(:queen, :diamonds))
      |> Trick.play_card(Card.new(:ace, :spades))

    assert Trick.winning_player(trick, :hearts) == 3
  end

  test "A trick is complete with 4 cards" do
    assert Trick.complete?(trick_with_n_cards(4))
  end

  defp trick_with_n_cards(n) do
    Trick.new(0, a_card()) |> play_n_cards(n - 1)
  end

  test "A trick is not complete with less than 4 cards" do
    assert not Trick.complete?(trick_with_n_cards(1))
    assert not Trick.complete?(trick_with_n_cards(2))
    assert not Trick.complete?(trick_with_n_cards(3))
  end

  test "The score of a trick includes all aces" do
    trick = create_trick([Card.new(:ace, :hearts), Card.new(:jack, :hearts), Card.new(:ace, :clubs), Card.new(:ace, :hearts)])
    assert Trick.score(trick) == 3
  end

  defp create_trick([head_card | rest_cards]) do
    trick = Trick.new(0, head_card)
    Enum.reduce(rest_cards, trick, fn card, acc -> Trick.play_card(acc, card) end)
  end
end
