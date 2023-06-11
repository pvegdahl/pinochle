defmodule PlayerViewTest do
  use ExUnit.Case

  alias Pinochle.{PlayerView, Game, TrickTaking}

  test "PlayerView has the correct player hand" do
    trick_taking = TrickTaking.new(2, :hearts)
    game = %Game{game_state: :trick_taking, data: trick_taking}
    player = 1

    player_view = PlayerView.from_game(game, player)

    assert player_view.hand == TrickTaking.hand(trick_taking, player)
  end
end
