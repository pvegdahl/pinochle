defmodule Pinochle.Meld do
  alias Pinochle.Card

  def score(hand, trump) do
    Enum.count(hand, fn %Card{suit: suit} -> suit == trump end)
  end
end