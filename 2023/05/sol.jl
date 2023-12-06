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

function travese_map(seed, map)
    for (dest, source, r) in eachrow(map)
        if (seed >= source) && (seed < source + r)
            offset = dest - source
            return offset + seed
        end
    end
    return seed
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

function create_bounds(lower, upper, bounds)
    new_bounds = []
    m = lower
    for (l, u) in bounds
        t = (m, l-1)
        if t[1] < t[2]
            push!(new_bounds, t)
        end
        m = u + 1
    end
    if  m < upper
        push!(new_bounds, (m, upper))
    end
    return new_bounds
end

function create_offset_dict(d, arr)
    offset_dict = Dict()
    for (lower, upper) in values(d)
        not_added = true
        for (dest, source, r) in eachrow(arr)
            map_lower = source
            map_upper = source + r - 1
            if map_lower <= lower <= map_upper || map_lower <= upper <= map_upper
                l = lower >= map_lower ? lower : map_lower
                u = upper <= map_upper ? upper : map_upper
                off = lower >= map_lower ? lower - map_lower : 0
                f = dest + off
                f = (f, f + (u - l))
                offset_dict[minimum((l, u)), maximum((l,u))] = minimum(f),maximum(f)
                not_added = false
                # if upper > map_upper
                #     offset_dict[map_upper+1, upper] = map_upper+1, upper
                # end
                # if lower > map_lower
                #     offset_dict[lower, map_lower-1] = lower, map_lower-1
                # end
            end
        end
        # add the identity mapping for all ranges that aren't mapped

        
        # if not_added
        #     offset_dict[lower, upper] = lower, upper
        # end
    end
    missing_intervals = get_missing_intervals(values(d), values(offset_dict))
    for (l, u) in missing_intervals
        offset_dict[l, u] = l, u
    end
    k_sum = 0
    v_sum = 0
    for (k, v) in offset_dict
        k_sum += k[2] - k[1] + 1
        v_sum += v[2] - v[1] + 1
    end
    if k_sum != v_sum
        throw("k_sum != v_sum")
        println("k_sum = $k_sum, v_sum = $v_sum")
    end
    
    return offset_dict
end
function get_missing_intervals(init_tuples, final_tuples)
    missing_intervals = []
    for init in init_tuples
        init_start, init_end = init
        overlap_found = false
        for final in final_tuples
            final_start, final_end = final
            if !(final_end < init_start || final_start > init_end)
                # Overlap found
                overlap_found = true
                if init_start < final_start
                    push!(missing_intervals, (init_start + 1, final_start - 1))
                end
                if init_end > final_end
                    push!(missing_intervals, (final_end + 1, init_end - 1))
                end
                break
            end
        end
        if !overlap_found
            push!(missing_intervals, init)
        end
    end
    return missing_intervals
end


function sol2(input)
    # get each array
    arrays = get_arrays(input)
    seeds = arrays[1]
    maps = arrays[2:end]
    seed_ranges = Dict()
    for i in 1:Int(length(seeds)/2)
        si = seeds[2*i-1]
        sr = seeds[2*i]
        seed_ranges[(si, si+sr-1)] = (si, si+sr-1)
    end
    offset_ranges = [seed_ranges]
    for (i, arr) in enumerate(maps)
        d = offset_ranges[i]
        offset_dict = create_offset_dict(d, arr)
        push!(offset_ranges, offset_dict)
    end
    return minimum([v[1] for v in values(offset_ranges[end])])
end

input = read("input", String)
v = sol1(input)
example_sol = sol2(example)
sol2(input)
# a = [88 18 7 ; 18 25 70]
# d = Dict([(81, 94) => (81,94)])
# create_offset_dict(d, a)

a2 = [45 77 23 ; 81 45 19 ; 68 64 13]
d2 = Dict([(81, 94) => (74,87)])
# create_offset_dict(d2, a2)
check = [82, 84, 84, 84, 77, 45, 46, 46]

a3 = [0 69 1 ; 1 0 69]
d3 = Dict([(77,87) => (45,55)])
# create_offset_dict(d3, a3)
a4 = [60 56 37 ; 56 93 4]
d4 = Dict([(45,55) => (46,56)])
create_offset_dict(d4, a4)
# create_offset_dict(d3, a3)
for (i, value) in enumerate(check)
    if i == length(check)
        break
    end
    m = example_sol[i+1]
    for (init, final) in m
        if init[1] <= value <= init[2]
            if final[1] <= check[i+1] <= final[2]
                println("true")
            else
                println("false")
                println("value = $value, check[i+1] = $(check[i+1])")
                println(i)
            end
        end
    end
end

# seeds, seed_map, soil_map, fertilizer_map, water_map, light_map, temperature_map, humidity_map = parse_input(example)


# s = to_array(soil_map)
# travese_map(14, s)
# seed_to_soil = test[2]

# s = to_array(seed_to_soil)

# s[1,:] .<= 50 .& s[2,:] .>= 50

# # Base.between.([2,2,1], s[:,1], s[:,2]) 

# travese_map(14, s)