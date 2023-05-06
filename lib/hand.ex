defmodule Pinochle.Hand do
  @type t :: [Pinochle.Card.t()]

  @spec deal() :: [Pinochle.Hand.t(), ...]
  def deal() do
    Pinochle.Card.deck()
    |> Enum.shuffle()
    |> Enum.chunk_every(12)
  end

  @spec remove_card(hand :: Pinochle.Hand.t(), card :: Pinochle.Card.t()) :: Pinochle.Hand.t()
  def remove_card(hand, card) do
    hand |> List.delete(card)
  end

  @spec remove_cards(hand :: Pinochle.Hand.t(), card :: [Pinochle.Card.t()]) :: Pinochle.Hand.t()
  def remove_cards(hand, cards) do
    Enum.reduce(cards, hand, &List.delete(&2, &1))
  end

  @spec add_cards(hand :: Pinochle.Hand.t(), card :: [Pinochle.Card.t()]) :: Pinochle.Hand.t()
  def add_cards(hand, cards) do
    cards ++ hand
  end

  @spec playable(hand :: Pinochle.Hand.t(), led_suit :: Pinochle.Card.suit(), winning_card :: Pinochle.Card.suit()) :: Pinochle.Hand.t()
  def playable(hand, _winning_card, _led_suit \\ nil, _trump \\ nil) do
    hand
  end
end
