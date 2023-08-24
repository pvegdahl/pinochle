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
    assert Meld.score([
      Card.new(:queen, :spades),
      Card.new(:jack, :diamonds),
    ], :clubs) == 4
  end

  test "A double pinochle is worth 30 points" do
    assert Meld.score([
             Card.new(:queen, :spades),
             Card.new(:queen, :spades),
             Card.new(:jack, :diamonds),
             Card.new(:jack, :diamonds),
           ], :diamonds) == 30
  end
end

# TODO
#   - Pinochles
#   - Runs
#     - Run + extra marriage
#   - X around
