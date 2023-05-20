defmodule Pinochle.Trick do
  alias Pinochle.Card, as: Card
  alias Pinochle.Trick, as: Trick

  @enforce_keys [:starting_player, :cards]
  defstruct [:starting_player, :cards]

  @type t :: %__MODULE__{starting_player: 0..3, cards: [Card.t(), ...]}

  @spec new(starting_player :: 0..3, card :: Card.t()) :: Trick.t()
  def new(starting_player, card), do: %Trick{starting_player: starting_player, cards: [card]}

  @spec current_player(trick :: Trick.t()) :: 0..3
  def current_player(%Trick{starting_player: starting_player, cards: cards}) do
    (starting_player + Enum.count(cards))
    |> Integer.mod(4)
  end

  @spec play_card(trick :: Trick.t(), card :: Card.t()) :: Trick.t()
  def play_card(%Trick{cards: cards} = trick, card) do
    %Trick{trick | cards: cards ++ [card]}
  end

  @spec winning_card(trick :: Trick.t(), trump :: Card.suit()) :: Card.t()
  def winning_card(%Trick{cards: cards}, trump) do
    cards
    |> Enum.reduce(&winner(&2, &1, trump))
  end

  @spec winner(first :: Card.t(), second :: Card.t(), trump :: Card.suit()) :: Card.t()
  defp winner(first, second, trump) do
    if(Card.first_wins?(first, second, trump), do: first, else: second)
  end

  @spec winning_player(trick :: Trick.t(), trump :: Card.suit()) :: 0..3
  def winning_player(%Trick{starting_player: starting_player, cards: cards} = trick, trump) do
    winning_card = winning_card(trick, trump)

    cards
    |> Enum.find_index(&(&1 == winning_card))
    |> then(&(&1 + starting_player))
    |> Integer.mod(4)
  end

  def cards(%Trick{cards: cards}), do: cards
end
