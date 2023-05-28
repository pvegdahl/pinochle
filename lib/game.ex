defmodule Pinochle.Game do
  alias Pinochle.{Game, Card, TrickTaking}

  @enforce_keys [:game_state]
  defstruct [:game_state, :data]

  @type game_state() :: :adding_players | :bidding | :selecting_trump | :passing | :passing_back | :trick_taking

  @type t :: %__MODULE__{game_state: game_state(), data: TrickTaking.t() | nil}

  @spec init(initial_state :: {0..3, Card.suit()}) :: {:ok, Game.t()}
  def init({starting_player, trump}) do
    # This is obviously not correct Pinochle, but the goal is to implement the full trick taking flow before anything
    # else.  Then I'll come back and make the other flows.
    game = %Game{game_state: :trick_taking, data: TrickTaking.new(starting_player, trump)}
    {:ok, game}
  end

  @spec start_link(starting_player :: 0..3, trump :: Card.suit()) :: GenServer.on_start()
  def start_link(starting_player \\ 0, trump \\ :spades) do
    GenServer.start_link(__MODULE__, {starting_player, trump})
  end

  def get(game) do
    GenServer.call(game, :get)
  end

  @spec handle_call(request :: :get, from :: pid(), state :: Game.t()) :: {:reply, Game.t(), Game.t()}
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
