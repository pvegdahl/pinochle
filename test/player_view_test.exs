defmodule PlayerViewTest do
  use ExUnit.Case

  alias Pinochle.{PlayerView, Game, Trick, TrickTaking}

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

  test "PlayerView contains hand sizes" do
    trick_taking = TrickTaking.new(0, :clubs)
    game = %Game{game_state: :trick_taking, data: trick_taking}

    player_view = PlayerView.from_game(game, 1)

    assert player_view.hand_sizes == [12, 12, 12, 12]
  end

  test "PlayerView contains latest trick" do
    trick_taking = TrickTaking.new(0, :clubs)
    card_in_hand = TrickTaking.hand(trick_taking, 0) |> List.first()
    {:ok, updated_trick_taking} = TrickTaking.play_card(trick_taking, 0, card_in_hand)
    game = %Game{game_state: :trick_taking, data: updated_trick_taking}

    player_view = PlayerView.from_game(game, 1)

    assert player_view.current_trick == Trick.new(0, card_in_hand)
  end

  test "PlayerView does not contain the latest trick when there is no latest trick" do
    trick_taking = TrickTaking.new(0, :clubs)
    game = %Game{game_state: :trick_taking, data: trick_taking}

    player_view = PlayerView.from_game(game, 1)

    assert player_view.current_trick == nil
  end
end
