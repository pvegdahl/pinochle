defmodule GameTest do
  use ExUnit.Case

  alias Pinochle.{Game, TrickTaking}

  test "A new game is in the trick taking state" do
    {:ok, game_pid} = Game.start_link()
    {:ok, game} = Game.get(game_pid)
    assert game.game_state == :trick_taking
  end

  test "Playing a card updates the state" do
    {:ok, game_pid} = Game.start_link()
    card_in_hand = get_card_in_active_player_hand(game_pid)

    :ok = Game.play_card(game_pid, 0, card_in_hand)

    {:ok, game} = Game.get(game_pid)

    player_zero_hand =
      game.data
      |> TrickTaking.hand(0)

    assert Enum.count(player_zero_hand) == 11
  end

  defp get_card_in_active_player_hand(game_pid) do
    game_pid
    |> active_player_hand()
    |> List.first()
  end

  defp active_player_hand(game_pid) do
    with {:ok, game} = Game.get(game_pid) do
      TrickTaking.current_hand(game.data)
    end
  end
end
