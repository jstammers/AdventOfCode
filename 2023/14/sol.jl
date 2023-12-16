using Memoization;
example = """O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#...."""

value_map = Dict(
    '.' => 0,
    'O' => 1,
    '#' => 2
)

function build_array(input)
    v = []
    for row in split(input, '\n')
        vs = []
        for col in row
            push!(vs, value_map[col])
        end
        if length(vs) > 0
            push!(v, vs)
        end
    end
    return transpose(stack(v))
end

function push_lever(array, direction)
    for (i,col) in enumerate(eachcol(array))
        array[:,i] = shift_rocks(col)
    end
    return array
end

function get_load(array)
    dist = reverse(collect(1:size(array, 1)))
    array = copy(array)
    array[array .== 2] .= 0
    return sum(array .* dist)
end

@memoize Dict function split_array(arr, indices)
    result = []
    if length(indices) == 0
        bounds = [(1, length(arr))]
    elseif length(indices) == 1
        if indices[1] == 1
            bounds = [(1, 1), (2, length(arr))]
        elseif indices[1] == length(arr)
            bounds = [(1, length(arr)-1), (length(arr), length(arr))]
        else
            bounds = [(1, indices[1]-1), (indices[1], length(arr))]
        end
    else
        if indices[1] > 1
            bounds = [(1, max(1,indices[1]-1))]
        else
            bounds = []
        end
        for i in 1:length(indices)-1
            push!(bounds, (indices[i], indices[i+1]-1))
        end
        if indices[end] != length(arr)
            push!(bounds, (indices[end], length(arr)))
        else
            push!(bounds, (indices[end], length(arr)))
        end
        
    end
    for (b1, b2) in bounds
        push!(result, sort(arr[b1:b2], rev=true))
    end
    result = collect(Iterators.flatten(result))
    if length(result) != length(arr)
        throw("Length of result is not equal to length of array")
    end
    return result
end

function shift_rocks(arr)
    rock_pos = findall(x->x==2, arr)
    return split_array(arr, rock_pos)
end

function sol1(input)
    array = build_array(input)
    array = push_lever(array, 1)
    return get_load(array)
end

function cycle_push(array)
    for i in 1:4
        array = push_lever(array, 1)
        array = rotr90(array)
    end
    return array
end


function array_value(array)
    lookup = Dict(
        0 => '.',
        1 => 'O',
        2 => '#'
    )
    s = []
    for row in eachrow(array)
        for col in row
            push!(s, lookup[col])
        end
        push!(s, '\n')
    end
    return join(s)
end

function sol2(input, num_cycles=10)
    array = build_array(input)
    array_values = []
    arrays = []
    println("Cycle 0: $(get_load(array))")
    for i in 1:num_cycles
        array = cycle_push(array)
        v = get_load(array)
        av = array_value(array)
        if av in arrays
            cycle_start = findfirst(x->x==av, arrays)
            cycle_length = 1 + length(arrays) - cycle_start
            cycle_index = cycle_start + (1000000000 - cycle_start ) % (cycle_length)
            return array_values[cycle_index ]
        else
            push!(array_values, v)
            push!(arrays, av)
        end
    end
    return array_values
end

sol1(example) == 136
av = sol2(example, 30)
input = read("2023/14/input", String)
sol1(input)
array_values = sol2(input, 500)