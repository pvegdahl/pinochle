defmodule Pinochle.Meld do
  alias Pinochle.{Card, Hand}

  @spec score(hand :: Hand.t(), trump :: Card.suit()) :: non_neg_integer()
  def score(hand, trump) do
    card_frequencies = Hand.frequencies(hand)

    score_nines(card_frequencies, trump) +
      score_marriages_non_trump(hand, trump) +
      score_marriages_of_trump(card_frequencies, trump)
  end

  @spec score_marriages_non_trump(hand :: Hand.t(), trump :: Card.suit()) :: 0..12
  defp score_marriages_non_trump(hand, trump), do: 2 * count_marriages_non_trump(hand, trump)

  @spec count_marriages_non_trump(hand :: Hand.t(), trump :: Card.suit()) :: 0..6
  defp count_marriages_non_trump(hand, trump) do
    hand_without_trump = Enum.reject(hand, fn card -> card.suit == trump end)
    queen_suits = count_suits_of_rank(hand_without_trump, :queen)
    king_suits = count_suits_of_rank(hand_without_trump, :king)

    min_of_two_maps(queen_suits, king_suits)
    |> Map.values()
    |> Enum.sum()
  end

  @spec count_suits_of_rank(hand :: Hand.t(), rank :: Card.rank()) :: %{Card.suit() => 1..2}
  defp count_suits_of_rank(hand, rank) do
    hand
    |> Enum.filter(fn card -> card.rank == rank end)
    |> Enum.frequencies_by(fn card -> card.suit end)
  end

  @spec score_marriages_of_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0..8
  defp score_marriages_of_trump(card_frequencies, trump), do: 4 * count_marriages_of_trump(card_frequencies, trump)

  @spec count_marriages_of_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0..2
  defp count_marriages_of_trump(card_frequencies, trump) do
    [Card.new(:queen, trump), Card.new(:king, trump)]
    |> Enum.map(&Map.get(card_frequencies, &1, 0))
    |> Enum.min()
  end

  @spec min_of_two_maps(map1 :: map(), map2 :: map()) :: map()
  defp min_of_two_maps(map1, map2) do
    Map.intersect(map1, map2, fn _k, v1, v2 -> min(v1, v2) end)
  end

  @spec score_marriages_of_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0..2
  defp score_nines(card_frequencies, trump) do
    Map.get(card_frequencies, Card.new(:nine, trump), 0)
  end
end
