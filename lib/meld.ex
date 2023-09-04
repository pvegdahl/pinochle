defmodule Pinochle.Meld do
  @moduledoc false

  alias Pinochle.{Card, Hand}

  @spec score(hand :: Hand.t(), trump :: Card.suit()) :: non_neg_integer()
  def score(hand, trump) do
    card_frequencies = Hand.frequencies(hand)

    score_nines_of_trump(card_frequencies, trump) +
      score_marriages_non_trump(card_frequencies, trump) +
      score_marriages_of_trump(card_frequencies, trump) +
      score_pinochle(card_frequencies) +
      score_rank_around(card_frequencies, :ace, 10) +
      score_rank_around(card_frequencies, :king, 8) +
      score_rank_around(card_frequencies, :queen, 6) +
      score_rank_around(card_frequencies, :jack, 4) +
      score_runs_in_trump(card_frequencies, trump)
  end

  @spec show(hand :: Hand.t(), trump :: Card.suit()) :: %{Card.t() => 1..2}
  def show(hand, trump) do
    card_frequencies = Hand.frequencies(hand)

    nines = show_nines_of_trump(card_frequencies, trump)
    marriages = show_marriages(card_frequencies)
    runs_in_trump = show_runs_in_trump(card_frequencies, trump)
    pinochle = show_pinochle(card_frequencies)
    aces_around = show_rank_around(card_frequencies, :ace)
    kings_around = show_rank_around(card_frequencies, :king)
    queens_around = show_rank_around(card_frequencies, :queen)
    jacks_around = show_rank_around(card_frequencies, :jack)

    merge_max_card_count(nines, marriages)
    |> merge_max_card_count(pinochle)
    |> merge_max_card_count(runs_in_trump)
    |> merge_max_card_count(aces_around)
    |> merge_max_card_count(kings_around)
    |> merge_max_card_count(queens_around)
    |> merge_max_card_count(jacks_around)
    |> reject_cards_with_zeroes()
  end

  defp merge_max_card_count(card_frequencies1, card_frequencies2) do
    Map.merge(card_frequencies1, card_frequencies2, fn _key, value1, value2 -> max(value1, value2) end)
  end

  defp reject_cards_with_zeroes(card_frequencies) do
    Map.reject(card_frequencies, fn {_key, value} -> value == 0 end)
  end

  @spec score_marriages_non_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0..12
  defp score_marriages_non_trump(card_frequencies, trump), do: 2 * count_marriages_non_trump(card_frequencies, trump)

  @spec count_marriages_non_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0..6
  defp count_marriages_non_trump(card_frequencies, trump) do
    non_trump_suits(trump)
    |> Enum.map(fn suit -> count_marriages_of_suit(card_frequencies, suit) end)
    |> Enum.sum()
  end

  @spec show_marriages(card_frequencies :: %{Card.t() => 1..2}) :: %{Card.t() => 0..2}
  defp show_marriages(card_frequencies) do
    Card.suits()
    |> Enum.map(fn suit -> {suit, count_marriages_of_suit(card_frequencies, suit)} end)
    |> Enum.flat_map(fn {suit, count} -> [{Card.new(:king, suit), count}, {Card.new(:queen, suit), count}] end)
    |> Enum.into(Map.new())
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
    count_marriages_of_suit(card_frequencies, trump) - count_runs_in_trump(card_frequencies, trump)
  end

  @spec count_card_collection(card_frequencies :: %{Card.t() => 1..2}, card_collection :: [Card.t()]) :: 0..2
  defp count_card_collection(card_frequencies, card_collection) do
    card_collection
    |> Enum.map(&Map.get(card_frequencies, &1, 0))
    |> Enum.min()
  end

  @spec score_nines_of_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0..2
  defp score_nines_of_trump(card_frequencies, trump) do
    count_nines_of_trump(card_frequencies, trump)
  end

  @spec count_nines_of_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0..2
  defp count_nines_of_trump(card_frequencies, trump) do
    Map.get(card_frequencies, Card.new(:nine, trump), 0)
  end

  @spec show_nines_of_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: %{Card.t() => 1..2}
  defp show_nines_of_trump(card_frequencies, trump) do
    %{Card.new(:nine, trump) => count_nines_of_trump(card_frequencies, trump)}
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

  @spec show_pinochle(card_frequencies :: %{Card.t() => 1..2}) :: %{Card.t() => 0..2}
  defp show_pinochle(card_frequencies) do
    count = count_pinochle(card_frequencies)

    %{
      Card.new(:jack, :diamonds) => count,
      Card.new(:queen, :spades) => count
    }
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

  @spec show_rank_around(card_frequencies :: %{Card.t() => 1..2}, rank :: Card.rank()) :: %{Card.t() => 0..2}
  defp show_rank_around(card_frequencies, rank) do
    count = count_rank_around(card_frequencies, rank)

    %{
      Card.new(rank, :clubs) => count,
      Card.new(rank, :diamonds) => count,
      Card.new(rank, :hearts) => count,
      Card.new(rank, :spades) => count
    }
  end

  @spec score_runs_in_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0 | 15 | 150
  defp score_runs_in_trump(card_frequencies, trump) do
    case count_runs_in_trump(card_frequencies, trump) do
      0 -> 0
      1 -> 15
      2 -> 150
    end
  end

  @spec count_runs_in_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: 0..2
  defp count_runs_in_trump(card_frequencies, trump) do
    count_card_collection(card_frequencies, [
      Card.new(:ace, trump),
      Card.new(:ten, trump),
      Card.new(:king, trump),
      Card.new(:queen, trump),
      Card.new(:jack, trump)
    ])
  end

  @spec show_runs_in_trump(card_frequencies :: %{Card.t() => 1..2}, trump :: Card.suit()) :: %{Card.t() => 0..2}
  defp show_runs_in_trump(card_frequencies, trump) do
    count = count_runs_in_trump(card_frequencies, trump)

    %{
      Card.new(:ace, trump) => count,
      Card.new(:ten, trump) => count,
      Card.new(:king, trump) => count,
      Card.new(:queen, trump) => count,
      Card.new(:jack, trump) => count
    }
  end
end
