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

  test "PlayerView has the correct game state" do
    trick_taking = TrickTaking.new(2, :hearts)
    game = %Game{game_state: :trick_taking, data: trick_taking}
    player = 1

    player_view = PlayerView.from_game(game, player)

    assert player_view.game_state == :trick_taking
  end

  test "PlayerView has the correct current_player" do
    current_player = 2
    trick_taking = TrickTaking.new(current_player, :hearts)
    game = %Game{game_state: :trick_taking, data: trick_taking}
    player = 1

    player_view = PlayerView.from_game(game, player)

    assert player_view.current_player == current_player
  end
end

# TODO:
#  - Trump
#  - Current trick (or all tricks?)
#  - Other player hand sizes
