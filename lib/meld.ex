defmodule Pinochle.Meld do
  alias Pinochle.Card

  def score(hand, trump) do
    nines(hand, trump) + marriages(hand, trump)
  end

  defp marriages(hand, _trump) do
    queen_suits = count_suits_of_rank(hand, :queen)
    king_suits = count_suits_of_rank(hand, :king)

    min_of_two_maps(queen_suits, king_suits)
    |> Map.values()
    |> Enum.sum()
    |> Kernel.*(2)
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
