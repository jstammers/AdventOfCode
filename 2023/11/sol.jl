using Combinatorics;
example = """...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#....."""

space = '.'
galaxy = '#'
# find the shortest distance between each pair of galaxies (#)
# any rows or columns that contain no galaxies should be twice as big

function build_map(input)
    lines = split(input, "\n")
    return stack([collect(l) for l in lines], dims=1)
end

function expand_space(space_map)
    new_map = []
    for row in eachrow(space_map)
        push!(new_map, row)
        if all(row .== space)
            push!(new_map, row)
        end
    end
    v = hcat(new_map...)
    v = permutedims(v)
    new_map = []
    for col in eachcol(v)
        push!(new_map, col)
        if all(col .== space)
            push!(new_map, col)
        end
    end
    return hcat(new_map...)
end

function expand_space(space_map, d=2)
    dist = ones(size(space_map))
    for i in 1:size(space_map, 1)
        r = space_map[i, :]
        if all(r .== space)
            dist[i, :] .= d
        end
    end
    for j in 1:size(space_map, 2)
        c = space_map[:, j]
        if all(c .== space)
            dist[:, j] .= d
        end
    end
    return dist
end

space_map = build_map(example)
v2 = expand_space(space_map)

function find_galaxies(m)
    galaxies = []
    for i in 1:size(m, 1)
        for j in 1:size(m, 2)
            if m[i, j] == '#'
                push!(galaxies, (i, j))
            end
        end
    end
    return galaxies
end

function find_galaxies(m, dist_map)
    galaxies = []
    for i in 1:size(m, 1)
        for j in 1:size(m, 2)
            if m[i, j] == '#'
                xd = Int(sum(dist_map[1:i, j]))
                yd = Int(sum(dist_map[i, 1:j]))
                push!(galaxies, (xd, yd))
            end
        end
    end
    return galaxies
end

function shortest_path(x1, y1, x2, y2)
    return abs(x1 - x2) + abs(y1 - y2)
end

function find_paths(galaxies)
    paths = []
    pairs = combinations(galaxies, 2)
    for (g1, g2) in pairs
        push!(paths, (g1, g2, shortest_path(g1..., g2...)))
    end
    return paths
end

galaxies = find_galaxies(v2)
v3 = expand_space(space_map, 2)

g2 = find_galaxies(space_map, v3)
paths = find_paths(g2)
function sol1(input)
    space_map = build_map(input)
    v2 = expand_space(space_map)
    galaxies = find_galaxies(v2)
    paths = find_paths(galaxies)
    return sum(x->x[3], paths)
end

function sol2(input, d=1000000)
    space_map = build_map(input)
    v2 = expand_space(space_map, d)
    galaxies = find_galaxies(space_map, v2)
    paths = find_paths(galaxies)
    return sum(x->x[3], paths)
end

sol1(example) == 374

input = read("2023/11/input", String)

sol1(input)
sol2(input)

sol2(example, 10) == 1030
sol2(example, 100) == 8410