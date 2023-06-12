defmodule Pinochle.PlayerView do
  alias Pinochle.{PlayerView, Card, Game, Hand, TrickTaking}

  @enforce_keys [:game_state, :current_player, :hand, :trump]
  defstruct [:game_state, :current_player, :hand, :trump]

  @type t :: %__MODULE__{game_state: Game.game_state(), current_player: 0..3, hand: Hand.t(), trump: Card.suit()}

  @spec from_game(game :: Game.t(), player :: 0..3) :: PlayerView.t()
  def from_game(%Game{game_state: :trick_taking, data: %TrickTaking{} = trick_taking} = game, player) do
    %PlayerView{
      game_state: :trick_taking,
      current_player: TrickTaking.current_player(trick_taking),
      hand: TrickTaking.hand(trick_taking, player),
      trump: TrickTaking.trump(trick_taking)
    }
  end
end
