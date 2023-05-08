defmodule TrickTest do
  use ExUnit.Case

  import Pinochle.Trick

  test "New tricks are empty" do
    assert new(0) |> Map.get(:cards) |> Enum.count() == 0
  end

  test "The current player for a new trick is the starting player" do
    0..3 |> Enum.each(fn n -> assert new(n) |> current_player() == n end)
  end

  test "Playing a card increments the current_player" do
    assert new(0) |> play_n_cards(1) |> current_player() == 1
    assert new(1) |> play_n_cards(2) |> current_player() == 3
  end

  defp play_n_cards(trick, 0), do: trick
  defp play_n_cards(trick, n) do
    trick
    |> play_card(Pinochle.Card.new(:jack, :diamonds))
    |> play_n_cards(n-1)
  end

  test "The current_player count wraps from 3 -> 0" do
    assert new(3) |> play_n_cards(1) |> current_player() == 0
    assert new(2) |> play_n_cards(3) |> current_player() == 1
  end
end
