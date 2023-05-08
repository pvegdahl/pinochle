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

  @spec first_wins?(first :: Pinochle.Card.t(), second :: Pinochle.Card.t(), trump :: suit() | nil) :: boolean()
  def first_wins?(first, second, trump \\ nil)

  def first_wins?(%Pinochle.Card{rank: rank_0, suit: suit}, %Pinochle.Card{rank: rank_1, suit: suit}, _trump) do
    rank_index(rank_0) >= rank_index(rank_1)
  end

  def first_wins?(_first, %Pinochle.Card{suit: trump}, trump), do: false
  def first_wins?(_first, _second, _trump), do: true

  @spec second_wins?(first :: Pinochle.Card.t(), second :: Pinochle.Card.t(), trump :: suit() | nil) :: boolean()
  def second_wins?(first, second, trump), do: !first_wins?(first, second, trump)

  @spec rank_index(rank :: rank()) :: integer
  def rank_index(rank), do: Enum.find_index(ranks(), fn r -> r == rank end)

  @spec deck() :: [Pinochle.Card.t(), ...]
  def deck() do
    for(rank <- ranks(), suit <- suits(), do: new(rank, suit))
    |> Enum.flat_map(&[&1, &1])
  end
end
