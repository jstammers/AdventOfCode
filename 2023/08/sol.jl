example = """RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)"""

function parse_input(input)
    lines = split(input, "\n")
    rule = lines[1]
    maps = lines[3:end]
    map_dict = Dict()
    for m in maps
        m = split(m, " = ")
        in = m[1]
        l = m[2][2:4]
        r = m[2][7:end-1]
        map_dict[in] = (l, r)
    end
    return rule, map_dict
end

test = parse_input(example)


function apply_rule(rule, map_dict)
    if rule == 'L'
        return map_dict[1]
    elseif rule == 'R'
        return map_dict[2]
    end
end

function count_steps(rule, map_dict, loc, part1 = true)
    i = 0
    num_steps = length(rule)
    while (loc != "ZZZ" && part1) || (loc[end] != 'Z' && !part1)
        next_rule = rule[(i % num_steps) + 1]
        m = map_dict[loc]
        loc = apply_rule(next_rule, m)
        i +=1
    end
    return i
end

function sol1(input)
    rule, map_dict = parse_input(input)
    return count_steps(rule, map_dict, "AAA")
end

sol1(example)


example_2 = """LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)"""

sol1(example_2)

input = read("2023/08/input", String)

# sol1(input)

function sol2(input)
    rule, map_dict = parse_input(input)
    locs = keys(map_dict)
    starting_locs = [k for k in locs if k[end] == 'A']
    num_steps = [count_steps(rule, map_dict, loc, false) for loc in starting_locs]
    return num_steps
end

example3 = """LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)"""

# sol2(example3)


v=sol2(input)

lcm(v)