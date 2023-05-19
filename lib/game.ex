defmodule Pinochle.Game do
  alias Pinochle.Game, as: Game
  alias Pinochle.Card, as: Card
  alias Pinochle.Hand, as: Hand
  alias Pinochle.Trick, as: Trick

  @enforce_keys [:current_player, :hands]
  defstruct [:current_player, :hands]

  @type t :: %__MODULE__{current_player: 0..3, hands: [Hand.t()]}

  @spec new(starting_player :: 0..3) :: Game.t()
  def new(starting_player), do: %Game{current_player: starting_player, hands: Hand.deal()}

  @spec current_player(game :: Game.t()) :: 0..3
  def current_player(%Game{current_player: current_player}), do: current_player

  @spec hand(game :: Game.t(), player :: 0..3) :: Hand.t()
  def hand(%Game{hands: hands}, player) do
    Enum.at(hands, player)
  end

  @spec play_card(game :: Game.t(), card :: Card.t()) :: Game.t()
  def play_card(%Game{current_player: current_player, hands: hands} = game, card) do
    new_current_player = Integer.mod(current_player + 1, 4)
    new_hand = current_hand(game) |> Hand.remove_card(card)
    new_hands = List.replace_at(hands, current_player, new_hand)

    %Game{game | current_player: new_current_player, hands: new_hands}
  end

  defp current_hand(%Game{current_player: current_player} = game) do
    game |> hand(current_player)
  end

  @spec current_trick(game :: Game.t()) :: Trick.t() | nil
  def current_trick(_game), do: nil
end
