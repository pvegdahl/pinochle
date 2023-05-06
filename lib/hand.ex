defmodule Pinochle.Hand do
  @spec deal() :: [[Pinochle.Card.t(), ...], ...]
  def deal() do
    Pinochle.Card.deck()
    |> Enum.shuffle()
    |> Enum.chunk_every(12)
  end
end
