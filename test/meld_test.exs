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
end