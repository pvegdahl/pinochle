defmodule Pinochle.Game do
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient

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

  @spec start_link(name :: String.t(), starting_player :: 0..3, trump :: Card.suit()) :: GenServer.on_start()
  def start_link(name, starting_player \\ 0, trump \\ :spades) do
    GenServer.start_link(__MODULE__, {starting_player, trump}, name: via_tuple(name))
  end

  @spec get(game_pid :: pid()) :: {:ok, Game.t()}
  def get(game_pid) do
    game = GenServer.call(game_pid, :get)
    {:ok, game}
  end

  @spec play_card(game_pid :: pid(), player :: 0..3, card :: Card.t()) :: :ok
  def play_card(game_pid, player, card) do
    GenServer.call(game_pid, {:play_card, player, card})
  end

  @spec handle_call(request :: :get | {:play_card, 0..3, Card.t()}, from :: GenServer.from(), game :: Game.t()) ::
          {:reply, Game.t() | :ok, Game.t()}
  def handle_call(:get, _from, game) do
    {:reply, game, game}
  end

  def handle_call(
        {:play_card, player, card},
        _from,
        %Game{game_state: :trick_taking, data: %TrickTaking{} = trick_taking} = game
      ) do
    with {:ok, new_trick_taking} <- TrickTaking.play_card(trick_taking, player, card) do
      {:reply, :ok, %Game{game | data: new_trick_taking}}
    else
      {:error, reason} -> {:reply, {:error, reason}, game}
    end
  end

  def via_tuple(name), do: {:via, Registry, {Registry.Game, name}}
end
