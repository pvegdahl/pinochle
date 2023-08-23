defmodule Pinochle.Meld do
  alias Pinochle.Card

  def score(hand, trump) do
    Enum.count(hand, fn card -> card == Card.new(:nine, trump) end)
  end
end