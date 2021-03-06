from typing import Tuple

import pytest

from pinochle.bidding import BiddingState
from pinochle.cards import CardDeck, Suit, Card, Rank
from pinochle.pinochle_game import PinochleGame, GameState


@pytest.fixture(scope="session")
def players() -> Tuple[str, str, str, str]:
    return "a", "b", "c", "d"


@pytest.fixture(scope="session")
def new_game(players: Tuple[str, str, str, str]) -> PinochleGame:
    return PinochleGame.new_game(players=players)


@pytest.fixture(scope="session")
def game_bidding_complete(players: Tuple[str, str, str, str]) -> PinochleGame:
    return PinochleGame(
        state=GameState.BIDDING,
        players=players,
        hands=CardDeck.deal(),
        bidding=BiddingState(active_players=("a",), current_bid=25),
        trump=None,
    )


@pytest.fixture(scope="session")
def game_ready_to_pass(players: Tuple[str, str, str, str]) -> PinochleGame:
    # For simplicity, we're setting up the hands so that player A has all clubs, B diamonds, C hearts, and D spades
    sorted_cards = tuple(sorted(CardDeck.all_cards()))
    return PinochleGame(
        state=GameState.PASSING_TO_BID_WINNER,
        players=players,
        hands=(
            sorted_cards[:12],
            sorted_cards[12:24],
            sorted_cards[24:36],
            sorted_cards[36:],
        ),
        bidding=BiddingState(active_players=("a",), current_bid=25),
        trump=Suit.CLUBS,
    )


@pytest.fixture(scope="session")
def passed_cards() -> Tuple[Card, Card, Card, Card]:
    return (
        Card(Rank.ACE, Suit.HEARTS),
        Card(Rank.ACE, Suit.HEARTS),
        Card(Rank.KING, Suit.HEARTS),
        Card(Rank.QUEEN, Suit.HEARTS),
    )


def test_new_game_state_is_bidding(new_game) -> None:
    assert new_game.state == GameState.BIDDING
    assert new_game.bidding is not None


def test_new_game_deals_cards_to_players(new_game) -> None:
    assert len(new_game.hands) == 4


def test_no_trump_at_start(new_game) -> None:
    assert new_game.trump is None


@pytest.mark.parametrize("trump_suit", [suit for suit in Suit])
def test_set_trump_does_what_it_says(trump_suit: Suit, game_bidding_complete: PinochleGame) -> None:
    game = game_bidding_complete.select_trump(player="a", trump=trump_suit)
    assert game.trump == trump_suit


def test_set_trump_advances_state_to_passing(
    game_bidding_complete: PinochleGame,
) -> None:
    game = game_bidding_complete.select_trump(player="a", trump=Suit.DIAMONDS)
    assert game.state == GameState.PASSING_TO_BID_WINNER
