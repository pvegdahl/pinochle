defmodule Pinochle.TrickTakingTestHelpers do
  @moduledoc false

  alias Pinochle.{Card, Trick, TrickTaking}

  @spec sorted_game(starting_player :: 0..3, trump :: Card.suit()) :: TrickTaking.t()
  def sorted_game(starting_player, trump \\ :clubs) do
    # Each player will have all cards of one suit: clubs, diamonds, hearts, spades
    hands =
      Card.deck()
      |> Enum.sort_by(fn card -> card.suit end)
      |> Enum.chunk_every(12)

    %TrickTaking{starting_player: starting_player, hands: hands, trump: trump}
  end

  @spec play_card(trick_taking :: TrickTaking.t(), card :: Card.t()) :: TrickTaking.t()
  def play_card(trick_taking, card) do
    current_player = TrickTaking.current_player(trick_taking)
    {:ok, updated_game} = TrickTaking.play_card(trick_taking, current_player, card)
    updated_game
  end

  @spec create_trick(starting_player :: 0..3, [Card.t()]) :: Trick.t()
  def create_trick(starting_player, [first_card | rest_of_cards]) do
    trick = Trick.new(starting_player, first_card)

    Enum.reduce(rest_of_cards, trick, fn card, acc -> Trick.play_card(acc, card) end)
  end
end
