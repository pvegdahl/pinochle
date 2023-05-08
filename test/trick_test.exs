defmodule TrickTest do
  use ExUnit.Case

  import Pinochle.Trick

  test "New tricks are empty" do
    assert new() |> Enum.count() == 0
  end
end
