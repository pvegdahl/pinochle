defmodule MeldTest do
  use ExUnit.Case, async: true

  alias Pinochle.Meld

  test "Empty hand is worth zero points" do
    assert Meld.score([]) == 0
  end
end