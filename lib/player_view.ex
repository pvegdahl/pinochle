defmodule Pinochle.PlayerView do
  alias Pinochle.{PlayerView, Game, Hand, TrickTaking}

  @enforce_keys [:game_state, :hand]
  defstruct [:game_state, :hand]

  @type t :: %__MODULE__{game_state: Game.game_state(), hand: Hand.t()}

  @spec from_game(game :: Game.t(), player :: 0..3) :: PlayerView.t()
  def from_game(%Game{game_state: :trick_taking, data: %TrickTaking{} = trick_taking} = game, player) do
    %PlayerView{game_state: :trick_taking, hand: TrickTaking.hand(trick_taking, player)}
  end
end
