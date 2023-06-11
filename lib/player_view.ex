defmodule Pinochle.PlayerView do
  alias Pinochle.{PlayerView, Game, Hand, TrickTaking}

  @enforce_keys [:hand]
  defstruct [:hand]

  @type t :: %__MODULE__{hand: Hand.t()}

  @spec from_game(game :: Game.t(), player :: 0..3) :: PlayerView.t()
  def from_game(%Game{data: %TrickTaking{} = trick_taking} = game, player) do
    %PlayerView{hand: TrickTaking.hand(trick_taking, player)}
  end
end
