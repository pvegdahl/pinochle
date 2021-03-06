import pytest

from pinochle.cards import Rank, CardDeck, Suit, Card


@pytest.mark.parametrize(
    "lower, higher",
    [
        (Rank.NINE, Rank.JACK),
        (Rank.NINE, Rank.QUEEN),
        (Rank.NINE, Rank.KING),
        (Rank.NINE, Rank.TEN),
        (Rank.NINE, Rank.ACE),
        (Rank.JACK, Rank.QUEEN),
        (Rank.JACK, Rank.KING),
        (Rank.JACK, Rank.TEN),
        (Rank.JACK, Rank.ACE),
        (Rank.QUEEN, Rank.KING),
        (Rank.QUEEN, Rank.TEN),
        (Rank.QUEEN, Rank.ACE),
        (Rank.KING, Rank.TEN),
        (Rank.KING, Rank.ACE),
        (Rank.TEN, Rank.ACE),
    ],
)
def test_rank_ordering(lower, higher):
    assert lower < higher
    assert not lower >= higher


@pytest.mark.parametrize(
    "lower, higher",
    [
        (Suit.CLUBS, Suit.DIAMONDS),
        (Suit.CLUBS, Suit.HEARTS),
        (Suit.CLUBS, Suit.SPADES),
        (Suit.DIAMONDS, Suit.HEARTS),
        (Suit.DIAMONDS, Suit.SPADES),
        (Suit.HEARTS, Suit.SPADES),
    ],
)
def test_suit_ordering(lower, higher):
    assert lower < higher
    assert not lower >= higher


@pytest.mark.parametrize("suit", [pytest.param(suit, id=suit.name) for suit in Suit])
def test_twelve_of_each_suit_in_deck(suit):
    cards_of_suit = [card for card in CardDeck().all_cards() if card.suit == suit]
    assert len(cards_of_suit) == 12


@pytest.mark.parametrize("rank", [pytest.param(rank, id=rank.name) for rank in Rank])
def test_eight_of_each_rank_in_deck(rank):
    cards_of_rank = [card for card in CardDeck().all_cards() if card.rank == rank]
    assert len(cards_of_rank) == 8


@pytest.mark.parametrize(
    "card",
    [pytest.param(card, id=f"{card.rank.name} of {card.suit.name}") for card in set(CardDeck().all_cards())],
)
def test_each_card_exists_exactly_twice(card):
    assert len([c for c in CardDeck().all_cards() if c == card]) == 2


@pytest.mark.parametrize(
    "lower_card, higher_card",
    [
        (Card(Rank.NINE, Suit.CLUBS), Card(Rank.JACK, Suit.CLUBS)),
        (Card(Rank.KING, Suit.CLUBS), Card(Rank.KING, Suit.HEARTS)),
        (Card(Rank.ACE, Suit.CLUBS), Card(Rank.KING, Suit.HEARTS)),
    ],
)
def test_card_ordering(lower_card, higher_card):
    assert lower_card < higher_card
    assert not lower_card > higher_card


class TestCardDeckShuffle:
    def test_all_cards_still_exist(self):
        _validate_all_cards_present(CardDeck._shuffled_cards())

    def test_shuffling_wont_repeat_anytime_in_1000_iterations(self):
        card_orders = set()
        for size in range(1, 1000):
            card_orders.add(CardDeck._shuffled_cards())
            assert len(card_orders) == size


def _validate_all_cards_present(cards):
    assert sorted(cards) == sorted(CardDeck.all_cards())


class TestCardDeckDeal:
    def test_four_hands(self):
        assert len(CardDeck().deal()) == 4

    def test_twelve_cards_per_hand(self):
        for hand in CardDeck().deal():
            assert len(hand) == 12

    def test_combine_hands_equals_deck(self):
        hands = CardDeck().deal()
        all_cards = []
        for hand in hands:
            all_cards.extend(hand)
        _validate_all_cards_present(all_cards)


class TestForMutMut:
    """
    These tests seem unnecessary, but they reduce MutMut noise
    """

    def test_enum_names(self):
        assert Suit.CLUBS.value == "Clubs"
        assert Suit.DIAMONDS.value == "Diamonds"
        assert Suit.HEARTS.value == "Hearts"
        assert Suit.SPADES.value == "Spades"

        assert Rank.NINE.value == "Nine"
        assert Rank.JACK.value == "Jack"
        assert Rank.QUEEN.value == "Queen"
        assert Rank.KING.value == "King"
        assert Rank.TEN.value == "Ten"
        assert Rank.ACE.value == "Ace"

    def test_enum_less_or_greater_than_self_checks(self):
        for suit in Suit:
            assert not suit < suit
            assert not suit > suit

        for rank in Rank:
            assert not rank < rank
            assert not rank > rank

    def test_card_less_or_greater_than_self_checks(self):
        card = Card(Rank.QUEEN, Suit.SPADES)
        assert not card < card
        assert not card > card
