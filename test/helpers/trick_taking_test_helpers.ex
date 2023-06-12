defmodule Pinochle.TrickTakingTestHelpers do
  alias Pinochle.{Card, TrickTaking}

  @spec sorted_game(starting_player :: 0..3, trump :: Card.suit()) :: TrickTaking.t()
  def sorted_game(starting_player, trump \\ :clubs) do
    # Each player will have all cards of one suit: clubs, diamonds, hearts, spades
    hands =
      Card.deck()
      |> Enum.sort_by(fn card -> card.suit end)
      |> Enum.chunk_every(12)

    %TrickTaking{starting_player: starting_player, hands: hands, trump: trump}
  end
end
