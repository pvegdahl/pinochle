defmodule Pinochle.Game do
  alias Pinochle.Game, as: Game
  alias Pinochle.Card, as: Card
  alias Pinochle.Hand, as: Hand
  alias Pinochle.Trick, as: Trick

  @enforce_keys [:starting_player, :hands, :trump]
  defstruct starting_player: nil, hands: nil, trump: nil, tricks: []

  @type t :: %__MODULE__{starting_player: 0..3, hands: [Hand.t()], tricks: [Trick.t()]}

  @spec new(starting_player :: 0..3, trump :: Card.suit()) :: Game.t()
  def new(starting_player, trump), do: %Game{starting_player: starting_player, hands: Hand.deal(), trump: trump}

  @spec current_player(game :: Game.t()) :: 0..3
  def current_player(%Game{starting_player: starting_player, tricks: []}), do: starting_player

  def current_player(%Game{trump: trump} = game) do
    trick = current_trick(game)

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
  def valid_play?(%Game{trump: trump} = game, card) do
    if new_trick?(game) do
      true
    else
      trick = current_trick(game)
      winning_card = Trick.winning_card(trick, trump)
      led_suit = Trick.led_suit(trick)

      current_hand(game)
      |> Hand.playable(winning_card, led_suit, trump)
      |> Enum.find(false, &(&1 == card))
    end
  end

  @spec new_trick?(game :: Game.t()) :: boolean()
  defp new_trick?(%Game{tricks: []}), do: true
  defp new_trick?(%Game{tricks: [head_trick | _]}), do: Trick.complete?(head_trick)

  @spec update_hand(game :: Game.t(), card :: Card.t()) :: Game.t()
  defp update_hand(%Game{hands: hands} = game, card) do
    current_player = Game.current_player(game)
    new_hand = current_hand(game) |> Hand.remove_card(card)
    %Game{game | hands: List.replace_at(hands, current_player, new_hand)}
  end

  @spec update_trick(game :: Game.t(), card :: Card.t()) :: Game.t()
  defp update_trick(%Game{tricks: []} = game, card) do
    update_game_with_new_trick(game, card)
  end

  defp update_trick(%Game{tricks: [head_trick | rest_tricks]} = game, card) do
    if new_trick?(game) do
      update_game_with_new_trick(game, card)
    else
      new_trick = Trick.play_card(head_trick, card)
      %Game{game | tricks: [new_trick | rest_tricks]}
    end
  end

  @spec update_game_with_new_trick(game :: Game.t(), card :: Card.t()) :: Game.t()
  defp update_game_with_new_trick(%Game{tricks: tricks} = game, card) do
    current_player = current_player(game)
    new_trick = Trick.new(current_player, card)
    %Game{game | tricks: [new_trick | tricks]}
  end

  @spec current_hand(game :: Game.t()) :: Hand.t()
  defp current_hand(%Game{} = game), do: game |> hand(Game.current_player(game))

  @spec current_trick(game :: Game.t()) :: Trick.t() | nil
  def current_trick(%Game{tricks: []}), do: nil
  def current_trick(%Game{tricks: [head_trick | _]}), do: head_trick

  @spec score_tricks(game :: Game.t()) :: %{(0..3) => 0..25}
  def score_tricks(%Game{tricks: tricks, trump: trump}) do
    scores = %{0 => 0, 1 => 0, 2 => 0, 3 => 0}

    tricks
    |> Enum.map(&score_and_assign_trick(&1, trump))
    |> add_point_for_last_trick(tricks, trump)
    |> Enum.reduce(scores, fn {player, score}, acc -> Map.update!(acc, player, &(&1 + score)) end)
  end

  @spec score_and_assign_trick(trick :: Trick.t(), trump :: Card.suit()) :: {0..3, 0..4}
  defp score_and_assign_trick(trick, trump) do
    winning_player = Trick.winning_player(trick, trump)
    score = Trick.score(trick)
    {winning_player, score}
  end

  @spec add_point_for_last_trick(player_scores :: [{0..3, 0..4}], tricks :: [Trick.t()], trump :: Card.suit()) :: [
          {0..3, 0..4}
        ]
  defp add_point_for_last_trick(player_scores, [head_trick | _rest_tricks] = tricks, trump) do
    if Enum.count(tricks) == 12 do
      winning_player = Trick.winning_player(head_trick, trump)
      [{winning_player, 1} | player_scores]
    else
      player_scores
    end
  end
end
