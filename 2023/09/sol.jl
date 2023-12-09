example = """0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"""

function parse_input(input)
    lines = split(input, "\n")
    return [parse.(Int, split(l, " ")) for l in lines]
end

function step_difference(arr, last=true)
    d = diff(vec(arr))
    if any(arr .!= 0)
        if last
            return arr[end] + step_difference(d, last)
        else
            return arr[1] - step_difference(d, last)
        end
    else
        if last
            return d[end]
        else
            return d[1]
        end
    end
end

function sol1(input)
    return sum(x->step_difference(x, true), parse_input(input))
end

function sol2(input)
    return sum(x->step_difference(x, false), parse_input(input))
end
    

sol1(example) == 114

input = read("2023/09/input", String)

sol1(input)
sol2(example)
sol2(input)
