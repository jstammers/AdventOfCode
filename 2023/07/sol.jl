
cards = ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]
card_maps = Dict()
for (i, c) in enumerate(cards)
    card_maps[c[1]] = 13 - i
end

cards2 = ["A", "K", "Q", "T", "9", "8", "7", "6", "5", "4", "3", "2", "J"]
card_maps2 = Dict()
for (i, c) in enumerate(cards2)
    card_maps2[c[1]] = 13 - i
end

example = """32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"""

function parse_input(input)
    hands = []
    bids = []
    for line in split(input, "\n")
        if length(line) == 0
            continue
        end
        hand = split(line, " ")
        push!(hands, hand[1])
        push!(bids, parse(Int, hand[2]))
    end
    return hands, bids
end


function getRank(hand)
    # if all cards the same, rank = 7
    # if found 4 of a kind, rank = 6
    # if found 3 and 2 of a kind, rank = 5
    # if found 3 of a kind, rank = 4
    # if found 2 pairs, rank = 3
    # if found 2 of a kind, rank = 2
    # else rank = 1

    card_counts = Dict()
    for card in hand
        if haskey(card_counts, card)
            card_counts[card] += 1
        else
            card_counts[card] = 1
        end
    end
    v = values(card_counts)
    if maximum(v) == 5
        # all cards the same
        return 1
    elseif maximum(v) == 4
        # four of a kind
        return 2
    elseif (maximum(v) == 3) && (minimum(v) == 2)
        # full house
        return 3
    elseif maximum(v) == 3
        # three of a kind
        return 4
    elseif (maximum(v) == 2) && (length(v) == 3)
        # two pairs
        return 5
    elseif maximum(v) == 2
        # two of a kind
        return 6
    else
        # high card
        return 7
    end
end


function most_common_char(s)
    d = Dict{Char, Int64}()
    for c in s
        if haskey(d, c)
            d[c] += 1
        else
            d[c] = 1
        end
    end
    m = maximum(values(d))
    for (k,v) in d
        if v == m
            return k
        end
    end
end

function getRank2(hand)
    # like get rank, but now a J is a wild card
    num_jokers = count(x->x=='J', hand)
    if num_jokers == 0
        return getRank(hand)
    elseif num_jokers == 5
        return 1
    else
        hand_no_jokers = filter(x->x!='J', hand)
        most_freq = most_common_char(hand_no_jokers)
        new_hand = replace(hand, 'J' => most_freq)
        return getRank(new_hand)

        rank = getRank(hand_no_jokers)
        # if 1 joker,
        # high_card -> one pair
        # one pair -> three of a kind
        # two pairs -> full house
        # full_house -> four of a kind
        # three of a kind -> four of a kind
        # four of a kind -> five of a kind
        j1_map = Dict(7 => 6, 6 => 4, 5 => 3, 4 => 2, 3 => 2, 2 => 1, 1 => 1)

        # if 2 jokers,
        # high_card -> three of a kind
        # one pair -> four of a kind
        # two pairs -> four of a kind
        # three of a kind -> five of a kind
        j2_map = Dict(7 => 4, 6 => 2, 5 => 2, 4 => 2, 3 => 1, 2 => 2, 1 => 1)
        # if 3 jokers,
        # high_card -> four of a kind
        # one pair -> five of a kind
        # two pairs -> five of a kind
        j3_map = Dict(7 => 2, 6 => 1, 5 => 1, 4 => 1, 3 => 1, 2 => 2, 1 => 1)
        if num_jokers == 1
            return j1_map[rank]
        elseif num_jokers == 2
            return j2_map[rank]
        elseif num_jokers == 3
            return j3_map[rank]
        elseif num_jokers == 4
            return 1
        else
            throw("too many jokers")
        end
    end
end

function hand_to_int(hand, card_map::Dict=card_maps)
    s = 0
    for (i, h) in enumerate(reverse(hand))
        s += card_map[h] * 13^(i-1)
    end
    return s
end

function groupHands(hands, rank_func::Function=getRank, card_map::Dict=card_maps)
    ranks = [Vector{String}() for i in 1:7]
    for hand in hands
        type = rank_func(hand)
        push!(ranks[type], hand)
    end
    # sort in order of the first card, then second etc.
    for i in 1:7
        sort!(ranks[i], by=x->hand_to_int(x, card_map), rev=true)
    end
    # return ranks
    v = []
    for i in 1:7
        for hand in ranks[i]
            push!(v, hand)
        end
    end
    n = length(v)
    rank_dict = Dict()
    for (r, h) in enumerate(v)
        rank_dict[h] = n - (r-1)
    end
    # concatenate all the ranks into one vector
    return rank_dict
end


v = groupHands(example_hands)

hand_to_int("KK667") > hand_to_int("KTJJT")
hand_to_int("QQQJA") > hand_to_int("T55J5")

example_hands, example_bids = parse_input(example)

example_ranks = [getRank(hand) for hand in example_hands]

function sol1(input)
    hands, bids = parse_input(input)
    ranks =  groupHands(hands)
    s = 0
    for (hand, bid) in zip(hands, bids)
        rank = ranks[hand]
        s += rank * bid
    end
    return s
end

function sol2(input)
    hands, bids = parse_input(input)
    ranks = groupHands(hands, getRank2, card_maps2)
    s = 0
    for (hand, bid) in zip(hands, bids)
        rank = ranks[hand]
        s += rank * bid
    end
    return s
end

sol1(example)

input = read("2023/07/input", String)

sol1(input)

sol2(example) == 5905

sol2(input)
hand_to_int("KK667", card_maps2) > hand_to_int("KTJJT", card_maps2)

hand_to_int("JKKK2", card_maps2) < hand_to_int("QQQQ2", card_maps2)