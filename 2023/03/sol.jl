example = permutedims(stack(collect.(split("467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...\$.*....
.664.598..", "\n"))))

# at every digit, concatenate the digits until a non-digit is reached

function get_number(arr, i, j)
    """Returns a list of adjacent indices"""
    path = []
    while true && j <= size(arr, 2)
        if !isdigit(arr[i, j])
            break
        end
        push!(path, arr[i, j])
        j += 1
    end
    digit = join(path, "")
    n = length(path)
    return digit, n
end

function get_numbers(arr)
    digits = digit_mask(arr)
    numbers = zeros(Int, size(arr))
    for i in axes(arr, 1), j in axes(arr, 2)
        if digits[i,j] == true && i <= size(arr, 1) && j <= size(arr, 2) && numbers[i, j] == 0
            digit, n = get_number(arr, i, j)
            numbers[i, j:j+n-1] .= parse(Int, digit)
        end
    end
    return numbers
end


function issymbol(c)
    return c != '.' && !isdigit(c)
end


function sym_mask(arr)
    """apply to every element of 2d array"""
    return map(issymbol, arr)
end

function digit_mask(arr)
    """apply to every element of 2d array"""
    return map(isdigit, arr)
end

function has_adj_symbol(sym_mask, i, j)
    """ returns true if there is a symbol adjacent to a digit. this can include diagonals"""
    imax = size(sym_mask, 1)
    jmax = size(sym_mask, 2)
    adjs = get_adj(i, j, imax, jmax)
    c = []
    for (ni, nj) in adjs
        if sym_mask[ni, nj] == true || sym_mask[ni, nj] > 0
            push!(c, sym_mask[ni, nj])
        end
    end
    return c
end

function get_adj(i, j, imax, jmax)
    """Returns a list of adjacent indices"""
    adj = []
    for di in -1:1
        for dj in -1:1
            if di == 0 && dj == 0
                continue
            end
            ni, nj = i + di, j + dj
            if 1 <= ni <= imax && 1 <= nj <= jmax
                push!(adj, (ni, nj))
            end
        end
    end
    return adj
end

function is_adjacent(arr)
    """ returns true if there is a symbol adjacent to a digit"""
    symbols = sym_mask(arr)
    digits = digit_mask(arr)
    adj_arr = falses(size(arr))
    for i in axes(arr, 1), j in axes(arr, 2)
        if (digits[i,j] == true) && (length(has_adj_symbol(symbols, i, j)) > 0)
            adj_arr[i,j] = true
        end
    end
    return adj_arr
end
tot1 = 0

function get_adjacent_numbers(arr)
    adj_arr = is_adjacent(arr)
    indices = findall(adj_arr)
    for i in indices
        if CartesianIndex(i[1],i[2]+1) in indices
            adj_arr[i[1],i[2]+1] = false
        end
    end
    return adj_arr
end

function sol1(arr)
    total = 0
    arr_numbers = get_numbers(arr)
    adj_numbers = get_adjacent_numbers(arr)
    for i in findall(adj_numbers)
        total += arr_numbers[i]
    end
    return total
end

function gear_mask(arr)
    return map(x -> x == '*', arr)
end

function get_num_adj_digits(arr)
    gears = gear_mask(arr)
    # digits = digit_mask(arr)
    adj_arr = zeros(Int, size(arr))
    adj_numbers = get_adjacent_numbers(arr)
    for ix in findall(gears)
        i,j = ix[1], ix[2]
        adj_arr[i,j] = length(has_adj_symbol(adj_numbers, i, j))
    end
    return adj_arr
end


function sol2(arr)
    total = 0
    arr_numbers = get_numbers(arr)
    adj_numbers = get_num_adj_digits(arr)
    for i in findall(x -> x == 2, adj_numbers)
        gear_adj = unique(has_adj_symbol(arr_numbers, i[1], i[2]))
        total += gear_adj[1] * gear_adj[2]
    end
    return total
end

example_sol = sol1(example)
input = permutedims(stack(collect.(readlines("03/input"))))
input_sol = sol1(input)

example_sol2 = sol2(example)

input_sol2 = sol2(input)