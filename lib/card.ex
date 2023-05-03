defmodule Pinochle.Card do
  @enforce_keys [:rank, :suit]
  defstruct [:rank, :suit]

  @spec new(rank :: atom(), suit :: atom()) :: Pinochle.Card.t()
  def new(rank, suit), do: %Pinochle.Card{rank: rank, suit: suit}

  @type t :: %__MODULE__{rank: atom(), suit: atom()}
end