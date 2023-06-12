defmodule Pinochle.TrickTaking do
  alias Pinochle.{TrickTaking, Card, Hand, Trick}

  @enforce_keys [:starting_player, :hands, :trump]
  defstruct starting_player: nil, hands: nil, trump: nil, tricks: []

  @type t :: %__MODULE__{starting_player: 0..3, hands: [Hand.t()], tricks: [Trick.t()]}

  @spec new(starting_player :: 0..3, trump :: Card.suit()) :: TrickTaking.t()
  def new(starting_player, trump), do: %TrickTaking{starting_player: starting_player, hands: Hand.deal(), trump: trump}

  @spec current_player(game :: TrickTaking.t()) :: 0..3
  def current_player(%TrickTaking{starting_player: starting_player, tricks: []}), do: starting_player

  def current_player(%TrickTaking{trump: trump} = game) do
    trick = current_trick(game)

    if Trick.complete?(trick) do
      Trick.winning_player(trick, trump)
    else
      Trick.current_player(trick)
    end
  end

  @spec hand(game :: TrickTaking.t(), player :: 0..3) :: Hand.t()
  def hand(%TrickTaking{hands: hands}, player) do
    Enum.at(hands, player)
  end

  @spec play_card(game :: TrickTaking.t(), player :: 0..3, card :: Card.t()) ::
          {:ok, TrickTaking.t()} | {:error, atom()}
  def play_card(game, player, card) do
    with(
      :ok <- validate_player(game, player),
      :ok <- validate_play(game, card)
    ) do
      updated_game =
        game
        |> update_hand(card)
        |> update_trick(card)

      {:ok, updated_game}
    end
  end

  @spec validate_player(game :: TrickTaking.t(), player :: 0..3) :: :ok | {:error, :inactive_player}
  defp validate_player(game, player) do
    if player == current_player(game) do
      :ok
    else
      {:error, :inactive_player}
    end
  end

  @spec validate_play(game :: TrickTaking.t(), card :: Card.t()) :: :ok | {:error, :invalid_card}
  def validate_play(game, card) do
    if valid_play?(game, card) do
      :ok
    else
      {:error, :invalid_card}
    end
  end

  @spec valid_play?(game :: TrickTaking.t(), card :: Card.t()) :: boolean()
  def valid_play?(%TrickTaking{trump: trump} = game, card) do
    if new_trick?(game) do
      current_hand(game)
      |> Enum.member?(card)
    else
      trick = current_trick(game)
      winning_card = Trick.winning_card(trick, trump)
      led_suit = Trick.led_suit(trick)

      current_hand(game)
      |> Hand.playable(winning_card, led_suit, trump)
      |> Enum.member?(card)
    end
  end

  @spec new_trick?(game :: TrickTaking.t()) :: boolean()
  defp new_trick?(%TrickTaking{tricks: []}), do: true
  defp new_trick?(%TrickTaking{tricks: [head_trick | _]}), do: Trick.complete?(head_trick)

  @spec update_hand(game :: TrickTaking.t(), card :: Card.t()) :: TrickTaking.t()
  defp update_hand(%TrickTaking{hands: hands} = game, card) do
    current_player = TrickTaking.current_player(game)
    new_hand = current_hand(game) |> Hand.remove_card(card)
    %TrickTaking{game | hands: List.replace_at(hands, current_player, new_hand)}
  end

  @spec update_trick(game :: TrickTaking.t(), card :: Card.t()) :: TrickTaking.t()
  defp update_trick(%TrickTaking{tricks: []} = game, card) do
    update_game_with_new_trick(game, card)
  end

  defp update_trick(%TrickTaking{tricks: [head_trick | rest_tricks]} = game, card) do
    if new_trick?(game) do
      update_game_with_new_trick(game, card)
    else
      new_trick = Trick.play_card(head_trick, card)
      %TrickTaking{game | tricks: [new_trick | rest_tricks]}
    end
  end

  @spec update_game_with_new_trick(game :: TrickTaking.t(), card :: Card.t()) :: TrickTaking.t()
  defp update_game_with_new_trick(%TrickTaking{tricks: tricks} = game, card) do
    current_player = current_player(game)
    new_trick = Trick.new(current_player, card)
    %TrickTaking{game | tricks: [new_trick | tricks]}
  end

  @spec current_hand(game :: TrickTaking.t()) :: Hand.t()
  def current_hand(%TrickTaking{} = game), do: game |> hand(TrickTaking.current_player(game))

  @spec current_trick(game :: TrickTaking.t()) :: Trick.t() | nil
  def current_trick(%TrickTaking{tricks: []}), do: nil
  def current_trick(%TrickTaking{tricks: [head_trick | _]}), do: head_trick

  @spec score_tricks(game :: TrickTaking.t()) :: %{(0..3) => 0..25}
  def score_tricks(%TrickTaking{tricks: tricks, trump: trump}) do
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

  @spec trump(trick_taking :: TrickTaking.t()) :: Card.suit()
  def trump(%TrickTaking{trump: trump}), do: trump

  @spec hands(trick_taking :: TrickTaking.t()) :: [Hand.t()]
  def hands(%TrickTaking{hands: hands}), do: hands
end
