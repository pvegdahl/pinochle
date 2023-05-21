defmodule Pinochle.Game do
  alias Pinochle.Game, as: Game
  alias Pinochle.Card, as: Card
  alias Pinochle.Hand, as: Hand
  alias Pinochle.Trick, as: Trick

  @enforce_keys [:starting_player, :hands, :trump]
  defstruct starting_player: nil, hands: nil, trick: nil, trump: nil

  @type t :: %__MODULE__{starting_player: 0..3, hands: [Hand.t()], trick: Trick.t() | nil}

  @spec new(starting_player :: 0..3, trump :: Card.suit()) :: Game.t()
  def new(starting_player, trump), do: %Game{starting_player: starting_player, hands: Hand.deal(), trump: trump}

  @spec current_player(game :: Game.t()) :: 0..3
  def current_player(%Game{starting_player: starting_player, trick: nil}), do: starting_player

  def current_player(%Game{trick: trick, trump: trump}) do
    if Trick.complete?(trick) do
      Trick.winning_player(trick, trump)
    else
      Trick.current_player(trick)
    end
  end

  @spec hand(game :: Game.t(), player :: 0..3) :: Hand.t()
  def hand(%Game{hands: hands}, player) do
    Enum.at(hands, player)
  end

  @spec play_card(game :: Game.t(), card :: Card.t()) :: Game.t()
  def play_card(game, card) do
    game
    |> update_hand(card)
    |> update_trick(card)
  end

  @spec update_hand(game :: Game.t(), card :: Card.t()) :: Game.t()
  defp update_hand(%Game{hands: hands} = game, card) do
    current_player = Game.current_player(game)
    new_hand = current_hand(game) |> Hand.remove_card(card)
    %Game{game | hands: List.replace_at(hands, current_player, new_hand)}
  end

  @spec update_trick(game :: Game.t(), card :: Card.t()) :: Game.t()
  defp update_trick(%Game{trick: nil, starting_player: starting_player} = game, card) do
    %Game{game | trick: Trick.new(starting_player, card)}
  end

  defp update_trick(%Game{trick: trick, trump: trump} = game, card) do
    if Trick.complete?(trick) do
      winning_player = Trick.winning_player(trick, trump)
      %Game{game | trick: Trick.new(winning_player, card)}
    else
      %Game{game | trick: Trick.play_card(trick, card)}
    end
  end

  @spec current_hand(game :: Game.t()) :: Hand.t()
  defp current_hand(%Game{} = game), do: game |> hand(Game.current_player(game))

  @spec current_trick(game :: Game.t()) :: Trick.t() | nil
  def current_trick(%Game{trick: trick}), do: trick
end
