defmodule Pinochle.PlayerView do
  @moduledoc false

  alias Pinochle.{PlayerView, Card, Game, Hand, Trick, TrickTaking}

  @enforce_keys [:game_state, :current_player, :hand, :trump, :hand_sizes]
  defstruct [:game_state, :current_player, :hand, :trump, :hand_sizes, :current_trick]

  @type t :: %__MODULE__{
          game_state: Game.game_state(),
          current_player: 0..3,
          hand: Hand.t(),
          trump: Card.suit(),
          hand_sizes: [0..16],
          current_trick: Trick.t() | nil
        }

  @spec from_game(game :: Game.t(), player :: 0..3) :: PlayerView.t()
  def from_game(%Game{game_state: :trick_taking, data: %TrickTaking{} = trick_taking}, player) do
    %PlayerView{
      game_state: :trick_taking,
      current_player: TrickTaking.current_player(trick_taking),
      hand: TrickTaking.hand(trick_taking, player),
      trump: TrickTaking.trump(trick_taking),
      hand_sizes: TrickTaking.hands(trick_taking) |> Enum.map(&Enum.count/1),
      current_trick: TrickTaking.current_trick(trick_taking)
    }
  end
end
