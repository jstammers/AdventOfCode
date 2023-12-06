example = """Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"""

function parse_input(input)
    cards = Dict()
    for line in split(input, '\n')
        card, numbers = split(line, ':')
        winning_str, card_str = split(numbers, " | ")
        winning_str = strip(winning_str)
        card_str = strip(card_str)
        winning_numbers = parse.(Int, filter(x -> !isempty(x) && isdigit(x[1]),split(winning_str, " ")))
        card_numbers = parse.(Int, filter(x -> !isempty(x)  && isdigit(x[1]),split(card_str, " ")))
        cards[parse(Int, card[6:end])] = [winning_numbers, card_numbers]
    end
    return cards
end

function score(winning_numbers, card_numbers)
    num_matches = 0
    for number in card_numbers
        if number in winning_numbers
            num_matches += 1
        end
    end
    if num_matches == 0
        return 0
    end
    return 2 ^ (num_matches - 1)
end

test = parse_input(example)

function sol1(input)
    cards = parse_input(input)
    total = 0
    for (card, numbers) in cards
        s = score(numbers[1], numbers[2])
        total += s
    end
    return total
end

function sol2(input)
    cards = parse_input(input)
    card_copy = Dict()
    for card in 1:length(cards)
        card_copy[card] = 1
    end
    for card in 1:length(cards)
        numbers = cards[card]
        s = score(numbers[1], numbers[2])
        if s > 0
            v = Int(log2(s) + 1)
            for i in 1:v
                if card + i < length(cards)
                    card_copy[card + i] += card_copy[card]
                end
            end
        end
    end
    return sum(values(card_copy))
end

score(test[1][1], test[1][2])

input = join(readlines("04/input"), "\n")
sol1(input)

sol2(example)
sol2(input)