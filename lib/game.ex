defmodule Pinochle.Game do
  alias Pinochle.Game, as: Game
  alias Pinochle.Hand, as: Hand

  @enforce_keys [:current_player, :hands]
  defstruct [:current_player, :hands]

  @type t :: %__MODULE__{current_player: 0..3, hands: [Hand.t()]}

  @spec new(starting_player :: 0..3) :: Game.t()
  def new(starting_player), do: %Game{current_player: starting_player, hands: Hand.deal()}

  @spec current_player(game :: Game.t()) :: 0..3
  def current_player(%Game{current_player: current_player}), do: current_player

  def hand(%Game{hands: hands}, player) do
    Enum.at(hands, player)
  end

  def play_card(%Game{current_player: current_player, hands: hands} = game, card) do
    new_current_player = Integer.mod(current_player + 1, 4)
    new_hands = hands |> Enum.map(&Hand.remove_card(&1, card))

    %Game{game | current_player: new_current_player, hands: new_hands}
  end

  defp current_hand(%Game{current_player: current_player} = game) do
    game |> hand(current_player)
  end
end
