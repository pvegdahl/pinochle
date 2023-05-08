defmodule Pinochle.Trick do
  @enforce_keys [:starting_player, :cards]
  defstruct [:starting_player, :cards]

  @type t :: %__MODULE__{starting_player: 0..3, cards: [Pinochle.Card.t()]}

  @spec new(starting_player :: 0..3) :: Pinochle.Trick.t()
  def new(starting_player), do: %Pinochle.Trick{starting_player: starting_player, cards: []}

  @spec current_player(trick :: Pinochle.Trick.t()) :: 0..3
  def current_player(%Pinochle.Trick{starting_player: starting_player, cards: cards}) do
    (starting_player + Enum.count(cards))
    |> Integer.mod(4)
  end

  @spec play_card(trick :: Pinochle.Trick.t(), card :: Pinochle.Card.t()) :: Pinochle.Trick.t()
  def play_card(%Pinochle.Trick{cards: cards} = trick, card) do
    %Pinochle.Trick{trick | cards: [card | cards]}
  end
end
