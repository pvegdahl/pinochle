defmodule Pinochle.Trick do

  defstruct [:starting_player, :cards]

  @type t :: %__MODULE__{starting_player: 0..3, cards: [Pinochle.Card.t()]}

  @spec new(starting_player :: 0..3) :: Pinochle.Trick.t()
  def new(starting_player), do: %Pinochle.Trick{starting_player: starting_player, cards: []}

  def current_player(%Pinochle.Trick{starting_player: starting_player, cards: cards}) do
    (starting_player + Enum.count(cards))
    |> Integer.mod(4)
  end

  def play_card(%Pinochle.Trick{cards: cards} = trick, card) do
    %Pinochle.Trick{trick | cards: [card | cards]}
  end
end
