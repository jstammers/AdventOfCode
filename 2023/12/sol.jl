using Memoization;
operational = '.'
damaged = '#'
unknown = '?'

string_map = Dict('.' => 0, '?' => 1, '#' => 2)

example = """???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1"""

function count_combs(str)
    spring_map, counts = split(str, " ")
    counts = parse.(Int, split(counts, ","))
    return count_string(spring_map, counts)
end


@memoize Dict function count_string(spring_map, counts)
    total = sum(counts)
    if spring_map != ""
        min_value = sum(x -> x == damaged, spring_map)
        max_value = sum(x -> (x in [damaged,unknown]), spring_map)
    else
        min_value = 0
        max_value = 0
    end
    if (min_value > total) || (max_value < total)
        return 0
    end
    if total == 0
        return 1
    end
    if spring_map[1] == operational
        return count_string(spring_map[2:end], counts)
    end
    if spring_map[1] == damaged
        l = counts[1]
        if match_beginning(spring_map, l)
            if l == length(spring_map)
                return 1
            end
            return count_string(spring_map[l+2:end], counts[2:end])
        end
        return 0
    end
    return count_string(spring_map[2:end], counts) + count_string('#' * spring_map[2:end], counts)
end

function match_beginning(data, l)
    c1 = all(map(x->(x in [damaged, unknown]), collect(data[1:l])))
    c2 = (length(data) == l) || (data[l+1] .== operational) || (data[l+1] .== unknown)
    return c1 && c2
end

# count_string(test_str, counts) == 1

function sol1(input)
    total = 0
    for (i,line) in enumerate(split(input, "\n"))
        c = count_combs(line)
        total += c
    end
    return total
end

function dupe_line(line)
    spring_map, counts = split(line, " ")
    spring_map = join([spring_map, spring_map, spring_map, spring_map, spring_map], "?")
    counts = join([counts, counts, counts, counts, counts], ",")
    return join([spring_map, counts], " ")
end

function sol2(input)
    total = 0
    for (i,line) in enumerate(split(input, "\n"))
        d1 = dupe_line(line)
        c = count_combs(d1)
        total += c
    end
    return total
end

input = read("2023/12/input", String)

sol1(input)

@time sol2(input)



