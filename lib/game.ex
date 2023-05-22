defmodule Pinochle.Game do
  alias Pinochle.Game, as: Game
  alias Pinochle.Card, as: Card
  alias Pinochle.Hand, as: Hand
  alias Pinochle.Trick, as: Trick

  @enforce_keys [:starting_player, :hands, :trump]
  defstruct starting_player: nil, hands: nil, trick: nil, trump: nil, tricks: []

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

  @spec play_card(game :: Game.t(), card :: Card.t()) :: {:ok, Game.t()} | {:error, atom()}
  def play_card(game, card) do
    if valid_play?(game, card) do
      updated_game =
        game
        |> update_hand(card)
        |> update_trick(card)

      {:ok, updated_game}
    else
      {:error, :invalid_card}
    end
  end

  @spec valid_play?(game :: Game.t(), card :: Card.t()) :: boolean()
  def valid_play?(%Game{trick: nil}, _card), do: true

  def valid_play?(%Game{trump: trump, trick: trick} = game, card) do
    if Trick.complete?(trick) do
      true
    else
      winning_card = Trick.winning_card(trick, trump)
      led_suit = Trick.led_suit(trick)

      current_hand(game)
      |> Hand.playable(winning_card, led_suit, trump)
      |> Enum.find(false, &(&1 == card))
    end
  end

  @spec update_hand(game :: Game.t(), card :: Card.t()) :: Game.t()
  defp update_hand(%Game{hands: hands} = game, card) do
    current_player = Game.current_player(game)
    new_hand = current_hand(game) |> Hand.remove_card(card)
    %Game{game | hands: List.replace_at(hands, current_player, new_hand)}
  end

  @spec update_trick(game :: Game.t(), card :: Card.t()) :: Game.t()
  defp update_trick(%Game{trick: nil, tricks: [], starting_player: starting_player} = game, card) do
    new_trick = Trick.new(starting_player, card)
    %Game{game | trick: new_trick, tricks: [new_trick]}
  end

  defp update_trick(%Game{trick: trick, tricks: [head_trick | rest_tricks] = tricks, trump: trump} = game, card) do
    if Trick.complete?(trick) do
      winning_player = Trick.winning_player(trick, trump)
      new_trick = Trick.new(winning_player, card)
      %Game{game | trick: new_trick, tricks: [new_trick | tricks]}
    else
      new_trick = Trick.play_card(trick, card)
      %Game{game | trick: new_trick, tricks: [new_trick | rest_tricks]}
    end
  end

  @spec current_hand(game :: Game.t()) :: Hand.t()
  defp current_hand(%Game{} = game), do: game |> hand(Game.current_player(game))

  @spec current_trick(game :: Game.t()) :: Trick.t() | nil
  def current_trick(%Game{trick: trick}), do: trick
end
