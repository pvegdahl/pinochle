defmodule Pinochle.PlayerView do
  alias Pinochle.{PlayerView, Card, Game, Hand, TrickTaking}

  @enforce_keys [:game_state, :current_player, :hand, :trump, :hand_sizes]
  defstruct [:game_state, :current_player, :hand, :trump, :hand_sizes]

  @type t :: %__MODULE__{
          game_state: Game.game_state(),
          current_player: 0..3,
          hand: Hand.t(),
          trump: Card.suit(),
          hand_sizes: [0..16]
        }

  @spec from_game(game :: Game.t(), player :: 0..3) :: PlayerView.t()
  def from_game(%Game{game_state: :trick_taking, data: %TrickTaking{} = trick_taking}, player) do
    %PlayerView{
      game_state: :trick_taking,
      current_player: TrickTaking.current_player(trick_taking),
      hand: TrickTaking.hand(trick_taking, player),
      trump: TrickTaking.trump(trick_taking),
      hand_sizes: TrickTaking.hands(trick_taking) |> Enum.map(&Enum.count/1)
    }
  end
end
