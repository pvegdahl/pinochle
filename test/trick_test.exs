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
    assert Trick.new(0, a_card()) |> Trick.winning_card() == a_card()
  end

  test "First card wins if higher in same suit" do
    first = Card.new(:ten, :hearts)
    second = Card.new(:king, :hearts)
    assert Trick.new(0, first) |> Trick.play_card(second) |> Trick.winning_card() == first
  end

  test "Second card wins if higher in same suit" do
    first = Card.new(:king, :hearts)
    second = Card.new(:ten, :hearts)
    assert Trick.new(0, first) |> Trick.play_card(second) |> Trick.winning_card() == second
  end
end

# TODO
# - Get winning card
# - Get winning player
