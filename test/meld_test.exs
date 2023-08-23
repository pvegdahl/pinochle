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
end

# TODO
#   - Marriages of trump are more points
#   - Pinocholes
#   - Runs
#   - X around
