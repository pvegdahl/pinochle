defmodule Pinochle.Hand do
  @type t :: [Pinochle.Card, ...]

  @spec deal() :: [Pinochle.Hand.t(), ...]
  def deal() do
    Pinochle.Card.deck()
    |> Enum.shuffle()
    |> Enum.chunk_every(12)
  end
end
