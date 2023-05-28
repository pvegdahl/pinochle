defmodule Pinochle.Game do
  alias Pinochle.{Game, TrickTaking}

  @enforce_keys [:state]
  defstruct [:state, :data]

  @type state() :: :adding_players | :bidding | :selecting_trump | :passing | :passing_back | :trick_taking

  @type t :: %__MODULE__{state: state(), data: TrickTaking.t() | nil}

  @spec new() :: Game.t()
  def new() do
    # This is obviously not correct Pinochle, but the goal is to implement the full trick taking flow before anything
    # else.  Then I'll come back and make the other flows.
    %Game{state: :trick_taking, data: TrickTaking.new(0, :spades)}
  end
end