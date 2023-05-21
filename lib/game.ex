defmodule Pinochle.Game do
  alias Pinochle.Game, as: Game
  alias Pinochle.Card, as: Card
  alias Pinochle.Hand, as: Hand
  alias Pinochle.Trick, as: Trick

  @enforce_keys [:current_player, :starting_player, :hands, :trump]
  defstruct current_player: nil, starting_player: nil, hands: nil, trick: nil, trump: nil

  @type t :: %__MODULE__{current_player: 0..3, starting_player: 0..3, hands: [Hand.t()], trick: Trick.t() | nil}

  @spec new(starting_player :: 0..3, trump :: Card.suit()) :: Game.t()
  def new(starting_player, trump), do: %Game{current_player: starting_player, starting_player: starting_player, hands: Hand.deal(), trump: trump}

  @spec current_player(game :: Game.t()) :: 0..3
  def current_player(%Game{current_player: current_player}), do: current_player

  @spec hand(game :: Game.t(), player :: 0..3) :: Hand.t()
  def hand(%Game{hands: hands}, player) do
    Enum.at(hands, player)
  end

  @spec play_card(game :: Game.t(), card :: Card.t()) :: Game.t()
  def play_card(%Game{hands: hands, trick: trick} = game, card) do
    current_player = Game.current_player(game)
    new_current_player = Integer.mod(current_player + 1, 4)
    new_hand = current_hand(game) |> Hand.remove_card(card)
    new_hands = List.replace_at(hands, current_player, new_hand)

    new_trick = update_trick(trick, current_player, card)

    %Game{game | current_player: new_current_player, hands: new_hands, trick: new_trick}
  end

  @spec update_trick(trick :: Trick.t(), current_player :: 0..3, card :: Card.t()) :: Trick.t()
  defp update_trick(nil, current_player, card), do: Trick.new(current_player, card)
  defp update_trick(trick, _current_player, card), do: Trick.play_card(trick, card)

  @spec current_hand(game :: Game.t()) :: Hand.t()
  defp current_hand(%Game{} = game) do
    current_player = Game.current_player(game)
    game |> hand(current_player)
  end

  @spec current_trick(game :: Game.t()) :: Trick.t() | nil
  def current_trick(%Game{trick: trick}), do: trick
end
