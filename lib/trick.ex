defmodule Pinochle.Trick do
  alias Pinochle.{Trick, Card}

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
    # Although it is inefficient to construct the list like this, I'm intentionally doing it this way because:
    #   1) Every time we process the list, we need it in this order, so this avoids a bunch of calls to Enum.reverse.
    #   2) The list maxes out at size 4, so it's not particularly problematic anyway
    #   3) An in-order list is more intuitive (and thus less error prone) than a reverse-order list
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
    |> add(starting_player)
    |> Integer.mod(4)
  end

  @spec add(a :: integer(), b :: integer()) :: integer()
  defp add(a, b), do: a + b

  @spec cards(trick :: Trick.t()) :: [Card.t()]
  def cards(%Trick{cards: cards}), do: cards

  @spec complete?(trick :: Trick.t()) :: boolean()
  def complete?(%Trick{cards: cards}), do: Enum.count(cards) == 4

  @spec led_suit(trick :: Trick.t()) :: Card.suit()
  def led_suit(%Trick{cards: [%Card{suit: suit} | _]}), do: suit

  @spec score(trick :: Trick.t()) :: 0..4
  def score(%Trick{cards: cards}) do
    point_cards = MapSet.new([:ace, :ten, :king])

    cards
    |> Enum.filter(&MapSet.member?(point_cards, &1.rank))
    |> Enum.count()
  end
end
