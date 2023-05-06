defmodule HandTest do
  use ExUnit.Case

  import Pinochle.Hand

  test "New hands is 4 hands" do
    assert deal() |> Enum.count() == 4
  end

  test "Each hand has 12 cards" do
    deal()
    |> Enum.each(fn hand -> assert Enum.count(hand) == 12 end)
  end

  test "The hands combined make up the deck" do
    sorted_hands = deal() |> Enum.concat() |> Enum.sort()
    sorted_deck = Pinochle.Card.deck() |> Enum.sort()

    assert sorted_hands == sorted_deck
  end

  test "The hands are randomized" do
    assert deal() != deal()
  end

  test "The hands are randomized even when sorted" do
    assert sort_hands(deal()) != sort_hands(deal())
  end

  defp sort_hands(hands) do
    hands
    |> Enum.map(&Enum.sort/1)
    |> Enum.sort()
  end
end
