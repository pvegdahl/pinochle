defmodule MeldTest do
  use ExUnit.Case, async: true

  alias Pinochle.{Card, Meld}

  test "Empty hand is worth zero points" do
    assert Meld.score([], :clubs) == 0
  end

  test "A nine of trump is worth one point" do
    assert Meld.score([Card.new(:nine, :spades)], :spades) == 1
  end

  for suit <- [:clubs, :diamonds, :hearts] do
    test "A nine of (#{suit}) is worth zero points when trump is spades" do
      assert Meld.score([Card.new(:nine, unquote(suit))], :spades) == 0
    end
  end

  test "Two nines of trump are worth two points" do
    assert Meld.score(List.duplicate(Card.new(:nine, :clubs), 2), :clubs) == 2
  end

  for rank <- [:jack, :queen, :king, :ten, :ace] do
    test "A #{rank} of trump (in isolation) is worth no points" do
      assert Meld.score([Card.new(unquote(rank), :hearts)], :hearts) == 0
    end
  end

  test "An off-suit marriage is worth 2 points" do
    assert Meld.score([Card.new(:king, :hearts), Card.new(:queen, :hearts)], :diamonds) == 2
  end

  test "A marriage must be in the same suit" do
    assert Meld.score([Card.new(:king, :hearts), Card.new(:queen, :clubs)], :diamonds) == 0
  end

  test "Two marriages of the same suit score 4 points" do
    assert Meld.score(
             [
               Card.new(:king, :hearts),
               Card.new(:king, :hearts),
               Card.new(:queen, :hearts),
               Card.new(:queen, :hearts)
             ],
             :diamonds
           ) == 4
  end

  test "Marriages of trump score 4 points each" do
    assert Meld.score(
             [
               Card.new(:king, :hearts),
               Card.new(:queen, :hearts)
             ],
             :hearts
           ) == 4
  end

  test "A handful of different marriages and non-marriages across suits" do
    assert Meld.score(
             [
               Card.new(:king, :diamonds),
               Card.new(:queen, :diamonds),
               Card.new(:queen, :diamonds),
               Card.new(:king, :clubs),
               Card.new(:queen, :hearts),
               Card.new(:king, :spades),
               Card.new(:king, :spades),
               Card.new(:queen, :spades),
               Card.new(:queen, :spades)
             ],
             :spades
           ) == 10
  end

  test "A pinochle is worth 4 points" do
    assert Meld.score(
             [
               Card.new(:queen, :spades),
               Card.new(:jack, :diamonds)
             ],
             :clubs
           ) == 4
  end

  test "A double pinochle is worth 30 points" do
    assert Meld.score(
             [
               Card.new(:queen, :spades),
               Card.new(:queen, :spades),
               Card.new(:jack, :diamonds),
               Card.new(:jack, :diamonds)
             ],
             :diamonds
           ) == 30
  end

  for {rank, score} <- [{:ace, 10}, {:king, 8}, {:queen, 6}, {:jack, 4}] do
    test "#{rank}s around is #{score} points" do
      assert Meld.score(
               [
                 Card.new(unquote(rank), :clubs),
                 Card.new(unquote(rank), :diamonds),
                 Card.new(unquote(rank), :hearts),
                 Card.new(unquote(rank), :spades)
               ],
               :clubs
             ) == unquote(score)
    end
  end

  for {rank, score} <- [{:ace, 100}, {:king, 80}, {:queen, 60}, {:jack, 40}] do
    test "Double #{rank}s around is #{score} points" do
      assert Meld.score(
               [
                 Card.new(unquote(rank), :clubs),
                 Card.new(unquote(rank), :clubs),
                 Card.new(unquote(rank), :diamonds),
                 Card.new(unquote(rank), :diamonds),
                 Card.new(unquote(rank), :hearts),
                 Card.new(unquote(rank), :hearts),
                 Card.new(unquote(rank), :spades),
                 Card.new(unquote(rank), :spades)
               ],
               :hearts
             ) == unquote(score)
    end
  end

  test "A run in trump is worth 15" do
    assert Meld.score(
             [
               Card.new(:ace, :hearts),
               Card.new(:ten, :hearts),
               Card.new(:king, :hearts),
               Card.new(:queen, :hearts),
               Card.new(:jack, :hearts)
             ],
             :hearts
           ) == 15
  end

  test "A double run in trump is worth 150" do
    assert Meld.score(
             [
               Card.new(:ace, :hearts),
               Card.new(:ace, :hearts),
               Card.new(:ten, :hearts),
               Card.new(:ten, :hearts),
               Card.new(:king, :hearts),
               Card.new(:king, :hearts),
               Card.new(:queen, :hearts),
               Card.new(:queen, :hearts),
               Card.new(:jack, :hearts),
               Card.new(:jack, :hearts)
             ],
             :hearts
           ) == 150
  end

  test "A run not in trump is worth 2 (for the marriage)" do
    assert Meld.score(
             [
               Card.new(:ace, :clubs),
               Card.new(:ten, :clubs),
               Card.new(:king, :clubs),
               Card.new(:queen, :clubs),
               Card.new(:jack, :clubs)
             ],
             :diamonds
           ) == 2
  end

  test "A run plus an extra marriage in trump is worth 19" do
    assert Meld.score(
             [
               Card.new(:ace, :hearts),
               Card.new(:ten, :hearts),
               Card.new(:king, :hearts),
               Card.new(:queen, :hearts),
               Card.new(:jack, :hearts),
               Card.new(:king, :hearts),
               Card.new(:queen, :hearts)
             ],
             :hearts
           ) == 19
  end

  test "A run (15) + queens around (6) + an extra marriage (2) + a pinochle (4) + a nine of trump (1) is 28" do
    assert Meld.score(
             [
               Card.new(:ace, :diamonds),
               Card.new(:ten, :diamonds),
               Card.new(:king, :diamonds),
               Card.new(:queen, :diamonds),
               Card.new(:jack, :diamonds),
               Card.new(:queen, :clubs),
               Card.new(:queen, :hearts),
               Card.new(:queen, :spades),
               Card.new(:king, :hearts),
               Card.new(:nine, :diamonds)
             ],
             :diamonds
           ) == 28
  end

  test "Show no meld" do
    assert Meld.show(
             [
               Card.new(:nine, :diamonds),
               Card.new(:king, :diamonds),
               Card.new(:king, :spades),
               Card.new(:king, :clubs),
               Card.new(:jack, :clubs),
               Card.new(:ace, :clubs),
               Card.new(:ten, :clubs),
               Card.new(:nine, :spades)
             ],
             :clubs
           ) ==
             Map.new()
  end

  test "Show meld of one nine of trump" do
    assert Meld.show(
             [
               Card.new(:nine, :diamonds),
               Card.new(:king, :diamonds),
               Card.new(:nine, :spades)
             ],
             :diamonds
           ) ==
             %{Card.new(:nine, :diamonds) => 1}
  end

  test "Show meld of two nines of trump" do
    assert Meld.show(
             [
               Card.new(:nine, :diamonds),
               Card.new(:king, :diamonds),
               Card.new(:nine, :spades),
               Card.new(:nine, :spades)
             ],
             :spades
           ) ==
             %{Card.new(:nine, :spades) => 2}
  end

  test "Show meld of a marriage" do
    assert Meld.show(
             [
               Card.new(:king, :hearts),
               Card.new(:queen, :hearts)
             ],
             :spades
           ) ==
             %{
               Card.new(:king, :hearts) => 1,
               Card.new(:queen, :hearts) => 1
             }
  end

  test "Show meld of multiple non-trump marriages" do
    assert Meld.show(
             [
               Card.new(:king, :hearts),
               Card.new(:queen, :hearts),
               Card.new(:king, :hearts),
               Card.new(:queen, :hearts),
               Card.new(:king, :diamonds),
               Card.new(:queen, :diamonds)
             ],
             :spades
           ) ==
             %{
               Card.new(:king, :hearts) => 2,
               Card.new(:queen, :hearts) => 2,
               Card.new(:king, :diamonds) => 1,
               Card.new(:queen, :diamonds) => 1
             }
  end

  test "Show meld of a pinochle" do
    assert Meld.show(
             [
               Card.new(:queen, :spades),
               Card.new(:jack, :diamonds),
               Card.new(:ten, :diamonds)
             ],
             :spades
           ) ==
             %{
               Card.new(:jack, :diamonds) => 1,
               Card.new(:queen, :spades) => 1
             }
  end

  test "Show meld of a double pinochle" do
    assert Meld.show(
             [
               Card.new(:queen, :spades),
               Card.new(:queen, :spades),
               Card.new(:jack, :diamonds),
               Card.new(:jack, :diamonds),
               Card.new(:ace, :spades)
             ],
             :spades
           ) ==
             %{
               Card.new(:jack, :diamonds) => 2,
               Card.new(:queen, :spades) => 2
             }
  end

  test "Show meld with overlapping double marriage and single pinochle" do
    assert Meld.show(
             [
               Card.new(:king, :spades),
               Card.new(:king, :spades),
               Card.new(:queen, :spades),
               Card.new(:queen, :spades),
               Card.new(:jack, :diamonds)
             ],
             :clubs
           ) ==
             %{
               Card.new(:king, :spades) => 2,
               Card.new(:queen, :spades) => 2,
               Card.new(:jack, :diamonds) => 1
             }
  end

  test "Show meld of a trump marriage" do
    assert Meld.show(
             [
               Card.new(:king, :hearts),
               Card.new(:queen, :hearts)
             ],
             :hearts
           ) ==
             %{
               Card.new(:king, :hearts) => 1,
               Card.new(:queen, :hearts) => 1
             }
  end

  test "Show meld of a run in trump" do
    assert Meld.show(
             [
               Card.new(:ace, :hearts),
               Card.new(:ten, :hearts),
               Card.new(:king, :hearts),
               Card.new(:queen, :hearts),
               Card.new(:jack, :hearts),
               Card.new(:ten, :hearts),
               Card.new(:jack, :hearts),
               Card.new(:queen, :spades)
             ],
             :hearts
           ) ==
             %{
               Card.new(:ace, :hearts) => 1,
               Card.new(:ten, :hearts) => 1,
               Card.new(:king, :hearts) => 1,
               Card.new(:queen, :hearts) => 1,
               Card.new(:jack, :hearts) => 1
             }
  end

  test "Show meld of a run in trump plus an extra trump marriage" do
    assert Meld.show(
             [
               Card.new(:ace, :spades),
               Card.new(:ten, :spades),
               Card.new(:king, :spades),
               Card.new(:queen, :spades),
               Card.new(:jack, :spades),
               Card.new(:king, :spades),
               Card.new(:queen, :spades)
             ],
             :spades
           ) ==
             %{
               Card.new(:ace, :spades) => 1,
               Card.new(:ten, :spades) => 1,
               Card.new(:king, :spades) => 2,
               Card.new(:queen, :spades) => 2,
               Card.new(:jack, :spades) => 1
             }
  end

  test "Show a double run in trump" do
    assert Meld.show(
             [
               Card.new(:ace, :hearts),
               Card.new(:ten, :hearts),
               Card.new(:king, :hearts),
               Card.new(:queen, :hearts),
               Card.new(:jack, :hearts),
               Card.new(:ace, :hearts),
               Card.new(:ten, :hearts),
               Card.new(:king, :hearts),
               Card.new(:queen, :hearts),
               Card.new(:jack, :hearts)
             ],
             :hearts
           ) ==
             %{
               Card.new(:ace, :hearts) => 2,
               Card.new(:ten, :hearts) => 2,
               Card.new(:king, :hearts) => 2,
               Card.new(:queen, :hearts) => 2,
               Card.new(:jack, :hearts) => 2
             }
  end

  for rank <- [:ace, :king, :queen, :jack] do
    test "Show #{rank} around" do
      assert Meld.show(
               [
                 Card.new(unquote(rank), :clubs),
                 Card.new(unquote(rank), :diamonds),
                 Card.new(unquote(rank), :hearts),
                 Card.new(unquote(rank), :spades)
               ],
               :clubs
             ) == %{
               Card.new(unquote(rank), :clubs) => 1,
               Card.new(unquote(rank), :diamonds) => 1,
               Card.new(unquote(rank), :hearts) => 1,
               Card.new(unquote(rank), :spades) => 1
             }
    end
  end

  for rank <- [:ace, :king, :queen, :jack] do
    test "Show double #{rank} around" do
      assert Meld.show(
               [
                 Card.new(unquote(rank), :clubs),
                 Card.new(unquote(rank), :clubs),
                 Card.new(unquote(rank), :diamonds),
                 Card.new(unquote(rank), :diamonds),
                 Card.new(unquote(rank), :hearts),
                 Card.new(unquote(rank), :hearts),
                 Card.new(unquote(rank), :spades),
                 Card.new(unquote(rank), :spades)
               ],
               :clubs
             ) == %{
               Card.new(unquote(rank), :clubs) => 2,
               Card.new(unquote(rank), :diamonds) => 2,
               Card.new(unquote(rank), :hearts) => 2,
               Card.new(unquote(rank), :spades) => 2
             }
    end
  end

  test "Show a mix of cards:  run + queens around + an extra marriage + a pinochle + a nine of trump" do
    assert Meld.show(
             [
               Card.new(:ace, :diamonds),
               Card.new(:ten, :diamonds),
               Card.new(:king, :diamonds),
               Card.new(:queen, :diamonds),
               Card.new(:jack, :diamonds),
               Card.new(:queen, :clubs),
               Card.new(:queen, :hearts),
               Card.new(:queen, :spades),
               Card.new(:queen, :spades),
               Card.new(:king, :hearts),
               Card.new(:nine, :diamonds),
               Card.new(:jack, :clubs)
             ],
             :diamonds
           ) == %{
             Card.new(:ace, :diamonds) => 1,
             Card.new(:ten, :diamonds) => 1,
             Card.new(:king, :diamonds) => 1,
             Card.new(:queen, :diamonds) => 1,
             Card.new(:jack, :diamonds) => 1,
             Card.new(:queen, :clubs) => 1,
             Card.new(:queen, :hearts) => 1,
             Card.new(:queen, :spades) => 1,
             Card.new(:queen, :spades) => 1,
             Card.new(:king, :hearts) => 1,
             Card.new(:nine, :diamonds) => 1
           }
  end
end
