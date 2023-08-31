defmodule Pinochle.Meld do
  @moduledoc false

  alias Pinochle.{Card, Hand}

  @spec score(hand :: Hand.t(), trump :: Card.suit()) :: non_neg_integer()
  def score(hand, trump) do
    card_frequencies = Hand.frequencies(hand)

    score_nines(card_frequencies, trump) +
      score_marriages_non_trump(card_frequencies, trump) +
      score_marriages_of_trump(card_frequencies, trump) +
      score_pinochle(card_frequencies) +
      score_rank_around(card_frequencies, :ace, 10) +
      score_rank_around(card_frequencies, :king, 8) +
      score_rank_around(card_frequencies, :queen, 6) +
      score_rank_around(card_frequencies, :jack, 4)
  end

  @spec score_marriages_non_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0..12
  defp score_marriages_non_trump(card_frequencies, trump), do: 2 * count_marriages_non_trump(card_frequencies, trump)

  @spec count_marriages_non_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0..6
  defp count_marriages_non_trump(card_frequencies, trump) do
    non_trump_suits(trump)
    |> Enum.map(fn suit -> count_marriages_of_suit(card_frequencies, suit) end)
    |> Enum.sum()
  end

  defp non_trump_suits(trump), do: Card.suits() |> Enum.reject(&(&1 == trump))

  @spec count_marriages_of_suit(card_frequencies :: %{Card.t() => 1..2}, suit :: Card.suit()) :: 0..2
  defp count_marriages_of_suit(card_frequencies, suit) do
    count_card_collection(card_frequencies, [Card.new(:queen, suit), Card.new(:king, suit)])
  end

  @spec score_marriages_of_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0..8
  defp score_marriages_of_trump(card_frequencies, trump), do: 4 * count_marriages_of_trump(card_frequencies, trump)

  @spec count_marriages_of_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0..2
  defp count_marriages_of_trump(card_frequencies, trump) do
    count_marriages_of_suit(card_frequencies, trump)
  end

  @spec count_card_collection(card_frequencies :: %{Card.t() => 1..2}, card_collection :: [Card.t()]) :: 0..2
  defp count_card_collection(card_frequencies, card_collection) do
    card_collection
    |> Enum.map(&Map.get(card_frequencies, &1, 0))
    |> Enum.min()
  end

  @spec score_nines(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0..2
  defp score_nines(card_frequencies, trump) do
    Map.get(card_frequencies, Card.new(:nine, trump), 0)
  end

  @spec score_pinochle(card_frequencies :: %{Card.t() => 1..2}) :: 0 | 4 | 30
  defp score_pinochle(card_frequencies) do
    case count_pinochle(card_frequencies) do
      0 -> 0
      1 -> 4
      2 -> 30
    end
  end

  @spec count_pinochle(card_frequencies :: %{Card.t() => 1..2}) :: 0..2
  defp count_pinochle(card_frequencies) do
    count_card_collection(card_frequencies, [Card.new(:queen, :spades), Card.new(:jack, :diamonds)])
  end

  @spec score_rank_around(
          card_frequencies :: %{Card.t() => 1..2},
          rank :: Card.rank(),
          base_score :: pos_integer()
        ) :: non_neg_integer()
  defp score_rank_around(card_frequencies, rank, base_score) do
    case count_rank_around(card_frequencies, rank) do
      0 -> 0
      1 -> base_score
      2 -> 10 * base_score
    end
  end

  @spec count_rank_around(card_frequencies :: %{Card.t() => 1..2}, rank :: Card.rank()) :: 0..2
  defp count_rank_around(card_frequencies, rank) do
    aces_spec = for suit <- Card.suits(), do: Card.new(rank, suit)
    count_card_collection(card_frequencies, aces_spec)
  end
end
