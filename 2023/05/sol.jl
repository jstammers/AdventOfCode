example = """seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
"""


function to_array(s)
    v = []
    for l in split(s, "\n")
        if length(l) == 0
            continue
        end
        push!(v, [parse(Int, x) for x in split(l, " ")])
    end
    return transpose(stack(v))
end


function parse_input(input)
    seeds = match(r"seeds: (.*)\n", input).captures[1]
    seed_map = match(r"seed-to-soil map:\n((?:\d+ \d+ \d+\n)+)", input).captures[1]
    soil_map = match(r"soil-to-fertilizer map:\n((?:\d+ \d+ \d+\n)+)", input).captures[1]
    fertilizer_map = match(r"fertilizer-to-water map:\n((?:\d+ \d+ \d+\n)+)", input).captures[1]
    water_map = match(r"water-to-light map:\n((?:\d+ \d+ \d+\n)+)", input).captures[1]
    light_map = match(r"light-to-temperature map:\n((?:\d+ \d+ \d+\n)+)", input).captures[1]
    temperature_map = match(r"temperature-to-humidity map:\n((?:\d+ \d+ \d+\n)+)", input).captures[1]
    humidity_map = match(r"humidity-to-location map:\n((?:\d+ \d+ \d+\n)+)", input).captures[1]

    return (seeds, seed_map, soil_map, fertilizer_map, water_map, light_map, temperature_map, humidity_map)
end

test = parse_input(example)

function travese_map(seed::Int, map)
    for (dest, source, r) in eachrow(map)
        if (seed >= source) && (seed < source + r)
            offset = dest - source
            return offset + seed
        end
    end
    return seed
end

function travese_map(seed::Tuple, map)::Vector{Tuple{Int, Int}}
    s1, s2 = seed
    new_array = []
    offset_arr = []
    covered = []
    for (dest, source, r ) in eachrow(map)
        offset = dest - source
        map_range = (source, source + r - 1)
        push!(offset_arr, (map_range, offset))
    end
    sort!(offset_arr, by=x->x[1][1])
    for (map_range, offset) in offset_arr
        m = range_case(seed, map_range, offset)
        if m[1][1] != -1
            push!(new_array, m)
            push!(covered, m .- offset)
        end
    end
    if length(covered) == 0
        return [seed]
    end
    min_covered = minimum(x->x[1],covered)
    max_covered = maximum(x->x[2],covered)
    if min_covered > s1
        push!(new_array, (s1, min_covered - 1))
    end
    if max_covered < s2
        push!(new_array, (max_covered + 1, s2))
    end
    sort!(new_array, by=x->x[1][1])
    return new_array
end

function range_case(seed_range::Tuple{Int,Int}, map_range::Tuple{Int,Int}, offset::Int)::Tuple{Int,Int}
    if (seed_range[1] < map_range[1]) && (map_range[1] <= seed_range[2] <= map_range[2])
        # seed range starts before and ends within map range
        return (map_range[1] + offset, seed_range[2] + offset)
    elseif (seed_range[1] < map_range[1]) && (map_range[2] < seed_range[2])
        # seed range starts before and ends after map range
        return (seed_range[1] + offset, map_range[2] + offset)
    elseif (map_range[1] <= seed_range[1] <= map_range[2]) && (map_range[1] <= seed_range[2] <= map_range[2])
        # seed range starts and ends within map range
        return (seed_range[1] + offset, seed_range[2] + offset)
    elseif (map_range[1] < seed_range[1] < map_range[2]) && (seed_range[2] > map_range[2])
        # seed range starts before and ends in map range
        return (seed_range[1] + offset, map_range[2] + offset)
    end
    return (-1,-1)
end

function get_arrays(input)
    seeds, seed_map, soil_map, fertilizer_map, water_map, light_map, temperature_map, humidity_map = parse_input(input)
    seeds = [parse(Int, x) for x in split(seeds, " ")]
    seed_to_soil = to_array(seed_map)
    soil_to_fertilizer = to_array(soil_map)
    fertilizer_to_water = to_array(fertilizer_map)
    water_to_light = to_array(water_map)
    light_to_temperature = to_array(light_map)
    temperature_to_humidity = to_array(temperature_map)
    humidity_to_location = to_array(humidity_map)
    return (seeds, seed_to_soil, soil_to_fertilizer, fertilizer_to_water, water_to_light, light_to_temperature, temperature_to_humidity, humidity_to_location)
end

function get_seed_locations(input)
    seeds, seed_to_soil, soil_to_fertilizer, fertilizer_to_water, water_to_light, light_to_temperature, temperature_to_humidity, humidity_to_location = get_arrays(input)
    v = []
    for s in seeds
        sv = [s]
        for m in [seed_to_soil, soil_to_fertilizer, fertilizer_to_water, water_to_light, light_to_temperature, temperature_to_humidity, humidity_to_location]
            s = travese_map(s, m)
            push!(sv, s)
        end
        push!(v, sv)
    end
    return v
end


function sol1(input)
    values = stack(get_seed_locations(input))
    return minimum(values[end,:])
end

function sol2(input, test=nothing)

    # get each array
    arrays = get_arrays(input)
    seeds = arrays[1]
    maps = arrays[2:end]
    seed_ranges = Vector{Tuple{Int, Int}}()
    for i in 1:Int(length(seeds)/2)
        si = seeds[2*i-1]
        sr = seeds[2*i]
        push!(seed_ranges, (si, si + sr))
    end
    if test === nothing
        offset_ranges = [seed_ranges]
    else
        offset_ranges = [[test]]
    end
    # offset_ranges = [seed_ranges]

    for (i, arr) in enumerate(maps)
        t = Vector{Tuple{Int, Int}}()
        d = offset_ranges[i]
        for j in d
            m = travese_map(j, arr)::Vector{Tuple{Int, Int}}
            if m !== nothing
                append!(t, m)
            end
        end
        sort!(t, by=x->x[1])
        push!(offset_ranges, t)
    end
    return offset_ranges
end

input = read("2023/05/input", String)
println(sol1(input))
println(sol2(input))
