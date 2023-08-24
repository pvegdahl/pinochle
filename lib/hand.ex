defmodule Pinochle.Hand do
  alias Pinochle.{Hand, Card}

  @type t :: [Card.t()]

  @spec deal() :: [Hand.t(), ...]
  def deal() do
    Card.deck()
    |> Enum.shuffle()
    |> Enum.chunk_every(12)
  end

  @spec remove_card(hand :: Hand.t(), card :: Card.t()) :: Hand.t()
  def remove_card(hand, card) do
    hand |> List.delete(card)
  end

  @spec remove_cards(hand :: Hand.t(), card :: [Card.t()]) :: Hand.t()
  def remove_cards(hand, cards) do
    Enum.reduce(cards, hand, &List.delete(&2, &1))
  end

  @spec add_cards(hand :: Hand.t(), card :: [Card.t()]) :: Hand.t()
  def add_cards(hand, cards) do
    cards ++ hand
  end

  @spec playable(hand :: Hand.t(), winning_card :: Card.t(), led_suit :: Card.suit(), trump :: Card.suit()) :: [
          Card.t()
        ]
  def playable(hand, winning_card, led_suit, trump) do
    hand
    |> candidate_cards(led_suit)
    |> filter_winners_or_everything(winning_card, trump)
  end

  @spec frequencies(hand :: t()) :: %{Card.t() => 1..2}
  def frequencies(hand), do: Enum.frequencies(hand)

  @spec candidate_cards(hand :: Hand.t(), led_suit :: Card.suit()) :: [Card.t()]
  defp candidate_cards(hand, led_suit) do
    hand
    |> cards_in_suit(led_suit)
    |> default_when_empty(hand)
  end

  @spec filter_winners_or_everything(cards :: [Card.t()], winning_card :: Card.t(), trump :: Card.suit()) :: [Card.t()]
  defp filter_winners_or_everything(cards, winning_card, trump) do
    cards
    |> filter_cards_that_win(winning_card, trump)
    |> default_when_empty(cards)
  end

  @spec filter_cards_that_win(cards :: [Card.t()], winning_card :: Card.t(), trump :: Card.suit()) :: [Card.t()]
  defp filter_cards_that_win(cards, winning_card, trump) do
    cards |> Enum.filter(&Card.second_wins?(winning_card, &1, trump))
  end

  @spec cards_in_suit(hand :: Hand.t(), suit :: Card.suit()) :: [Card.t()]
  defp cards_in_suit(hand, suit) do
    hand |> Enum.filter(fn card -> card.suit == suit end)
  end

  @spec default_when_empty(list :: [Card.t()], default :: Hand.t()) :: [Card.t()]
  defp default_when_empty([], default), do: default
  defp default_when_empty(list, _default), do: list
end
