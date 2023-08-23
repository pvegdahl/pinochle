defmodule Pinochle.Meld do
  alias Pinochle.Card

  def score(hand, trump) do
    nines(hand, trump) + marriages(hand, trump)
  end

  defp marriages(hand, _trump) do
    kings = Enum.count(hand, fn %Card{rank: rank} -> rank == :king end)
    queens = Enum.count(hand, fn %Card{rank: rank} -> rank == :queen end)

    min(kings, queens) * 2
  end

  defp nines(hand, trump) do
    Enum.count(hand, fn card -> card == Card.new(:nine, trump) end)
  end
end