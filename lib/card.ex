defmodule Pinochle.Card do
  @enforce_keys [:rank, :suit]
  defstruct [:rank, :suit]

  @type suit() :: :diamonds | :clubs | :hearts | :spades

  @type rank() :: :nine | :jack | :queen | :king | :ten | :ace

  @spec new(rank :: rank(), suit :: suit()) :: Pinochle.Card.t()
  def new(rank, suit), do: %Pinochle.Card{rank: rank, suit: suit}

  @type t :: %__MODULE__{rank: rank(), suit: suit()}
end