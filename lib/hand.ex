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
  def playable(hand, winning_card, led_suit, trump) do
    hand
    |> candidate_cards(led_suit)
    |> filter_winners_or_everything(winning_card, trump)
  end

  @spec candidate_cards(hand :: Pinochle.Hand.t(), led_suit :: Pinochle.Card.suit()) :: [Pinochle.Card.t()]
  defp candidate_cards(hand, led_suit) do
    hand
    |> cards_in_suit(led_suit)
    |> default_when_empty(hand)
  end

  @spec filter_winners_or_everything(
          cards :: [Pinochle.Card.t()],
          winning_card :: Pinochle.Card.t(),
          trump :: Pinochle.Card.suit()
        ) :: [Pinochle.Card.t()]
  defp filter_winners_or_everything(cards, winning_card, trump) do
    cards
    |> filter_cards_that_win(winning_card, trump)
    |> default_when_empty(cards)
  end

  @spec filter_cards_that_win(
          cards :: [Pinochle.Card.t()],
          winning_card :: Pinochle.Card.t(),
          trump :: Pinochle.Card.suit()
        ) :: [Pinochle.Card.t()]
  defp filter_cards_that_win(cards, winning_card, trump) do
    cards |> Enum.filter(&(Pinochle.Card.second_wins?(winning_card, &1, trump)))
  end

  @spec cards_in_suit(hand :: Pinochle.Hand.t(), suit :: Pinochle.Card.suit()) :: [Pinochle.Card.t()]
  defp cards_in_suit(hand, suit) do
    hand |> Enum.filter(fn card -> card.suit == suit end)
  end

  @spec default_when_empty(list :: [Pinochle.Card.t()], default :: Pinochle.Hand.t()) :: [Pinochle.Card.t()]
  defp default_when_empty([], default), do: default
  defp default_when_empty(list, _default), do: list
end
