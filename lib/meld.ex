defmodule Pinochle.Meld do
  def score(hand, _trump) do
    Enum.count(hand)
  end
end