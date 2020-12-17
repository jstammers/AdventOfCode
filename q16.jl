"""
--- Day 16: Ticket Translation ---
As you're walking to yet another connecting flight, you realize that one of the legs of your re-routed trip coming up is on a high-speed train. However, the train ticket you were given is in a language you don't understand. You should probably figure out what it says before you get to the train station after the next flight.

Unfortunately, you can't actually read the words on the ticket. You can, however, read the numbers, and so you figure out the fields these tickets must have and the valid ranges for values in those fields.

You collect the rules for ticket fields, the numbers on your ticket, and the numbers on other nearby tickets for the same train service (via the airport security cameras) together into a single document you can reference (your puzzle input).

The rules for ticket fields specify a list of fields that exist somewhere on the ticket and the valid ranges of values for each field. For example, a rule like class: 1-3 or 5-7 means that one of the fields in every ticket is named class and can be any value in the ranges 1-3 or 5-7 (inclusive, such that 3 and 5 are both valid in this field, but 4 is not).

Each ticket is represented by a single line of comma-separated values. The values are the numbers on the ticket in the order they appear; every ticket has the same format. For example, consider this ticket:

.--------------------------------------------------------.
| ????: 101    ?????: 102   ??????????: 103     ???: 104 |
|                                                        |
| ??: 301  ??: 302             ???????: 303      ??????? |
| ??: 401  ??: 402           ???? ????: 403    ????????? |
'--------------------------------------------------------'
Here, ? represents text in a language you don't understand. This ticket might be represented as 101,102,103,104,301,302,303,401,402,403; of course, the actual train tickets you're looking at are much more complicated. In any case, you've extracted just the numbers in such a way that the first number is always the same specific field, the second number is always a different specific field, and so on - you just don't know what each position actually means!

Start by determining which tickets are completely invalid; these are tickets that contain values which aren't valid for any field. Ignore your ticket for now.

For example, suppose you have the following notes:

class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12
It doesn't matter which position corresponds to which field; you can identify invalid nearby tickets by considering only whether tickets contain values that are not valid for any field. In this example, the values on the first nearby ticket are all valid for at least one field. This is not true of the other three nearby tickets: the values 4, 55, and 12 are are not valid for any field. Adding together all of the invalid values produces your ticket scanning error rate: 4 + 55 + 12 = 71.

Consider the validity of the nearby tickets you scanned. What is your ticket scanning error rate?
"""


using Test
using DelimitedFiles

example = """class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12
"""

struct ValueRange
    name:: String
    range1::Tuple
    range2::Tuple
    ValueRange(name, range1, range2) = new(name, range1, range2)
end

function withinRange(tuple::Tuple, value)
    return tuple[1] <= value <= tuple[2]
end

function isValid(ranges, values)
    return [withinRange(x.range1,y) | withinRange(x.range2,y) for (x,y) in Iterators.product(ranges, values)]

end

function getErrorRate(ranges, tickets)
    s = 0
    for values in eachrow(tickets)
        valid_lines = [any(x) for x in eachcol(isValid(ranges, values))]
        n = values[.!valid_lines]
        s += sum(n)
    end
    return s
end

function getValidTickets(ranges, tickets)
    valid_tickets = []
    valid_bools = []
    for values in eachrow(tickets)
        valid_lines = [any(x) for x in eachcol(isValid(ranges, values))]
        n = values[.!valid_lines]
        if sum(n) == 0
            push!(valid_tickets, values)
            valid_locs = isValid(ranges, values)
            push!(valid_bools, valid_locs)
        end
    end
    return valid_tickets, valid_bools
end

function parseTuple(string)
    t = split(string,"-")
    return (parse(Int,(t[1])), parse(Int,t[2]))
end

function parseFields(string)
    r = []
    for line in eachline(IOBuffer(string))
        name = String(match(r"(\w*)", line).match)
        v1 = match(r"\d{1,3}-\d{1,3}",line)
        v2 = match(r"\d{1,3}-\d{1,3}", line, v1.offset+length(v1.match))
        v_r = ValueRange(name, parseTuple(v1.match), parseTuple(v2.match))
        push!(r,v_r)
    end
    return r
end

# r = [ValueRange((1,3),(5,7)), ValueRange((6,11),(33,44)), ValueRange((13,40),(45,50))]

t = readdlm(IOBuffer("""7,3,47
40,4,50
55,2,20
38,6,12"""), ',', Int, '\n')



v = parseFields("""class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50""");

@test getErrorRate(v,t) == 71

data = split(read("data/q16.txt", String),"\n\n");

value_ranges = parseFields(data[1]);

tickets = readdlm(IOBuffer(data[3][17:end]), ',',Int, '\n');

# getErrorRate(value_ranges, tickets)

"""
--- Part Two ---
Now that you've identified which tickets contain invalid values, discard those tickets entirely. Use the remaining valid tickets to determine which field is which.

Using the valid ranges for each field, determine what order the fields appear on the tickets. The order is consistent between all tickets: if seat is the third field, it is the third field on every ticket, including your ticket.

For example, suppose you have the following notes:

class: 0-1 or 4-19
row: 0-5 or 8-19
seat: 0-13 or 16-19

your ticket:
11,12,13

nearby tickets:
3,9,18
15,1,5
5,14,9
Based on the nearby tickets in the above example, the first position must be row, the second position must be class, and the third position must be seat; you can conclude that in your ticket, class is 12, row is 11, and seat is 13.

Once you work out which field is which, look for the six fields on your ticket that start with the word departure. What do you get if you multiply those six values together?
""" 

valid_tickets, valid_locations = getValidTickets(value_ranges, tickets);


v = parseFields("""class: 0-1 or 4-19
row: 0-5 or 8-19
seat: 0-13 or 16-19""");

t = readdlm(IOBuffer("""3,9,18
15,1,5
5,14,9"""), ',', Int, '\n')

vt, vl = getValidTickets(v,t);

function fillpositions(res, positions)
    if minimum(positions) > 0
        return positions
    else
        row_sum = sum(res, dims=2)
        locs = findall(x->x==1, row_sum)
        for l in locs
            pos = l.I[1]
            j = findmax(res[pos,:])[2]
            positions[pos] = j
            res[:,j] .= false
            positions = fillpositions(res, positions)
            println(positions)
        end
    end
    return positions
end

function boolarray(valid_locations)

    res = valid_locations[1]
    for v in valid_locations[2:end]
        res = res .& v
    end
    return res
end


function findPositions(valid_tickets, valid_locations)
    positions = zeros(length(valid_tickets[1]))
    res = boolarray(valid_locations)
    #TODO: make this recursive
    positions = fillpositions(res, positions)
    return positions
end


@test findPositions(vt,vl) == [2,1,3];


# @profview findPositions(vt,vl)
locs = findPositions(valid_tickets, valid_locations);
b = boolarray(valid_locations);
my_ticket = [151,71,67,113,127,163,131,59,137,103,73,139,107,101,97,149,157,53,109,61];

s = 1
for (i,l) in enumerate(locs)
    l = Int(l)
    v = value_ranges[i]
    if occursin("departure",v.name)
        s*= my_ticket[l]
    end
end
s

