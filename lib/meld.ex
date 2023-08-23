defmodule Pinochle.Meld do
  alias Pinochle.Card

  def score(hand, trump) do
    nines(hand, trump) + marriages_non_trump(hand, trump) + marriages_of_trump(hand, trump)
  end

  defp marriages_non_trump(hand, trump) do
    hand_without_trump = Enum.reject(hand, fn card -> card.suit == trump end)
    queen_suits = count_suits_of_rank(hand_without_trump, :queen)
    king_suits = count_suits_of_rank(hand_without_trump, :king)

    min_of_two_maps(queen_suits, king_suits)
    |> Map.values()
    |> Enum.sum()
    |> Kernel.*(2)
  end

  defp marriages_of_trump(hand, trump) do
    queen_of_trump = Card.new(:queen, trump)
    king_of_trump = Card.new(:king, trump)

    queens = Enum.count(hand, fn card -> card == queen_of_trump end)
    kings = Enum.count(hand, fn card -> card == king_of_trump end)

    min(queens, kings) * 4
  end

  defp count_suits_of_rank(hand, rank) do
    hand
    |> Enum.filter(fn card -> card.rank == rank end)
    |> Enum.frequencies_by(fn card -> card.suit end)
  end

  defp min_of_two_maps(map1, map2) do
    Map.intersect(map1, map2, fn _k, v1, v2 -> min(v1, v2) end)
  end

  defp nines(hand, trump) do
    Enum.count(hand, fn card -> card == Card.new(:nine, trump) end)
  end
end
