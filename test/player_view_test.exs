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

  test "PlayerView tracks trump" do
    trump = :diamonds
    trick_taking = TrickTaking.new(0, trump)
    game = %Game{game_state: :trick_taking, data: trick_taking}

    player_view = PlayerView.from_game(game, 1)

    assert player_view.trump == trump
  end
end

# TODO:
#  - Current trick (or all tricks?)
#  - Other player hand sizes
