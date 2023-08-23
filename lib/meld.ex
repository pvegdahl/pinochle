defmodule Pinochle.Meld do
  alias Pinochle.Card

  def score(hand, trump) do
    nines(hand, trump) + marriages(hand, trump)
  end

  defp marriages(hand, _trump) do
    queen_suits = suits_of_rank(hand, :queen)
    king_suits = suits_of_rank(hand, :king)

    MapSet.intersection(queen_suits, king_suits)
    |> MapSet.size()
    |> Kernel.*(2)
  end

  defp suits_of_rank(hand, rank) do
    hand
    |> Enum.filter(fn card -> card.rank == rank end)
    |> Enum.map(fn card -> card.suit end)
    |> Enum.into(MapSet.new())
  end

  defp nines(hand, trump) do
    Enum.count(hand, fn card -> card == Card.new(:nine, trump) end)
  end
end
