defmodule GameTest do
  use ExUnit.Case

  alias Pinochle.{Game, Card, TrickTaking}

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

  test "Playing out of turn returns an error" do
    {:ok, game_pid} = Game.start_link()

    assert Game.play_card(game_pid, 2, Card.new(:queen, :spades)) == {:error, :inactive_player}
  end

  test "An invalid play does not update the game state" do
    {:ok, game_pid} = Game.start_link()
    {:ok, original_game} = Game.get(game_pid)

    Game.play_card(game_pid, 2, Card.new(:queen, :spades))

    {:ok, updated_game} = Game.get(game_pid)
    assert updated_game == original_game
  end

  test "Playing a card not in hand is an error" do
    {:ok, game_pid} = Game.start_link()

    card_not_in_hand = get_card_not_in_active_player_hand(game_pid)

    assert Game.play_card(game_pid, 0, card_not_in_hand) == {:error, :invalid_card}
  end

  defp get_card_not_in_active_player_hand(game_pid) do
    cards_in_hand = active_player_hand(game_pid) |> MapSet.new()
    all_cards = Card.deck() |> MapSet.new()

    MapSet.difference(all_cards, cards_in_hand) |> Enum.take(1) |> List.first()
  end
end
