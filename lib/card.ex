defmodule Pinochle.Card do
  @enforce_keys [:rank, :suit]
  defstruct [:rank, :suit]

  @type suit() :: :diamonds | :clubs | :hearts | :spades

  @type rank() :: :nine | :jack | :queen | :king | :ten | :ace

  @spec new(rank :: rank(), suit :: suit()) :: Pinochle.Card.t()
  def new(rank, suit), do: %Pinochle.Card{rank: rank, suit: suit}

  @type t :: %__MODULE__{rank: rank(), suit: suit()}

  @spec ranks() :: [rank()]
  def ranks(), do: [:nine, :jack, :queen, :king, :ten, :ace]

  @spec suits() :: [suit()]
  def suits(), do: [:diamonds, :clubs, :hearts, :spades]

  @spec wins?(first :: Pinochle.Card.t(), second :: Pinochle.Card.t()) :: boolean()
  def wins?(_first, _second), do: true
end