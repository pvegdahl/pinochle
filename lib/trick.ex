defmodule Pinochle.Trick do
  @type t :: [Pinochle.Card.t()]

  @spec new() :: Pinochle.Trick.t()
  def new(), do: []
end
