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
      score_aces_around(card_frequencies) +
      score_kings_around(card_frequencies) +
      score_queens_around(card_frequencies) +
      score_jacks_around(card_frequencies)
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

  @spec score_aces_around(card_frequencies :: %{Card.t() => 1..2}) :: 0 | 10 | 100
  defp score_aces_around(card_frequencies) do
    case count_something_around(card_frequencies, :ace) do
      0 -> 0
      1 -> 10
      2 -> 100
    end
  end

  @spec score_kings_around(card_frequencies :: %{Card.t() => 1..2}) :: 0 | 8 | 80
  defp score_kings_around(card_frequencies) do
    case count_something_around(card_frequencies, :king) do
      0 -> 0
      1 -> 8
      2 -> 80
    end
  end

  @spec score_queens_around(card_frequencies :: %{Card.t() => 1..2}) :: 0 | 6 | 60
  defp score_queens_around(card_frequencies) do
    case count_something_around(card_frequencies, :queen) do
      0 -> 0
      1 -> 6
      2 -> 60
    end
  end

  @spec score_jacks_around(card_frequencies :: %{Card.t() => 1..2}) :: 0 | 4 | 40
  defp score_jacks_around(card_frequencies) do
    case count_something_around(card_frequencies, :jack) do
      0 -> 0
      1 -> 4
      2 -> 40
    end
  end

  @spec count_something_around(card_frequencies :: %{Card.t() => 1..2}, rank :: Card.rank()) :: 0..2
  defp count_something_around(card_frequencies, rank) do
    aces_spec = for suit <- Card.suits(), do: Card.new(rank, suit)
    count_card_collection(card_frequencies, aces_spec)
  end
end
