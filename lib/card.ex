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

  @spec wins?(first :: Pinochle.Card.t(), second :: Pinochle.Card.t(), trump :: suit() | nil) ::
          boolean()
  def wins?(first, second, trump \\ nil)

  def wins?(%Pinochle.Card{rank: rank_0, suit: suit}, %Pinochle.Card{rank: rank_1, suit: suit}, _trump) do
    rank_index(rank_0) >= rank_index(rank_1)
  end

  def wins?(_first, %Pinochle.Card{suit: trump}, trump), do: false

  def wins?(_first, _second, _trump), do: true

  @spec rank_index(rank :: rank()) :: integer
  def rank_index(rank), do: Enum.find_index(ranks(), fn r -> r == rank end)

  @spec deck() :: [Pinochle.Card.t(), ...]
  def deck() do
    for(rank <- ranks(), suit <- suits(), do: new(rank, suit))
    |> Enum.flat_map(&[&1, &1])
  end

  @spec hands() :: [[Pinochle.Card.t(), ...], ...]
  def hands() do
    deck()
    |> Enum.shuffle()
    |> Enum.chunk_every(12)
  end
end
