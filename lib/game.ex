defmodule Pinochle.Game do
  alias Pinochle.Game, as: Game

  @enforce_keys [:current_player]
  defstruct [:current_player]

  @type t :: %__MODULE__{current_player: 0..3}

  @spec new(starting_player :: 0..3) :: Game.t()
  def new(starting_player), do: %Game{current_player: starting_player}

  @spec current_player(game :: Game.t()) :: 0..3
  def current_player(%Game{current_player: current_player}), do: current_player
end
