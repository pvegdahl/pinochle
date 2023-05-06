defmodule Pinochle.Hand do
  @type t :: [Pinochle.Card]

  @spec deal() :: [Pinochle.Hand.t(), ...]
  def deal() do
    Pinochle.Card.deck()
    |> Enum.shuffle()
    |> Enum.chunk_every(12)
  end

  @spec remove(hand :: Pinochle.Hand.t(), card :: Pinochle.Card.t()) :: Pinochle.Hand.t()
  def remove(hand, card) do
    hand |> List.delete(card)
  end

  @spec remove_multiple(hand :: Pinochle.Hand.t(), card :: [Pinochle.Card.t()]) :: Pinochle.Hand.t()
  def remove_multiple(hand, cards) do
    Enum.reduce(cards, hand, &List.delete(&2, &1))
  end
end
