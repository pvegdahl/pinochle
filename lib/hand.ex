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

  @spec playable(
          hand :: Pinochle.Hand.t(),
          winning_card :: Pinochle.Card.t(),
          led_suit :: Pinochle.Card.suit(),
          trump :: Pinochle.Card.suit()
        ) :: Pinochle.Hand.t()
  def playable(hand, winning_card, _led_suit, trump) do
    hand
    |> Enum.filter(&(!Pinochle.Card.wins?(winning_card, &1)))
    |> try_trump(hand, trump)
    |> default_when_empty(hand)
  end

  @spec try_trump(playable :: [Pinochle.Card.t()], hand :: Pinochle.Hand.t(), trump :: Pinochle.Card.suit()) :: [
          Pinochle.Card.t()
        ]
  defp try_trump([], hand, trump), do: hand |> Enum.filter(fn card -> card.suit == trump end)
  defp try_trump(playable, _hand, _trump), do: playable

  @spec default_when_empty(list :: [Pinochle.Card.t()], default :: Pinochle.Hand.t()) :: [Pinochle.Card.t()]
  defp default_when_empty([], default), do: default
  defp default_when_empty(list, _default), do: list
end
