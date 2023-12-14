using Graphs;

vert = '|'
horiz = '-'
bend_ne = 'L'
bend_nw = 'J'
bend_sw = '7'
bend_se = 'F'
ground = '.'
start = 'S'


deltas = Dict(
    vert => [(1, 0), (-1, 0)],
    horiz => [(0, 1), (0, -1)],
    bend_ne => [(-1, 0), (0, 1)],
    bend_nw => [(-1, 0), (0, -1)],
    bend_se => [(1, 0), (0, 1)],
    bend_sw => [(1, 0), (0, -1)]
)

example = """.....
.S-7.
.|.|.
.L-J.
....."""

function build_map(input)
    lines = split(input, "\n")
    return stack([collect(l) for l in lines], dims=1)
end

function find_start(m)
    for i in 1:size(m, 1)
        for j in 1:size(m, 2)
            if m[i, j] == 'S'
                return (i, j)
            end
        end
    end
end

function infer_start_pipe(map, start)
    i, j = start
    map_n = i > 1 ? map[i-1, j] : ground
    map_s = i < length(map) ? map[i+1, j] : ground
    map_e = j < length(map) ? map[i, j+1] : grounf
    map_w = j > 1 ? map[i, j-1] : ground
    n_connects = map_n in [vert, bend_se, bend_sw]
    s_connects = map_s in [vert, bend_ne, bend_nw]
    e_connects = map_e in [horiz, bend_nw, bend_sw]
    w_connects = map_w in [horiz, bend_ne, bend_se]
    if n_connects && s_connects
        return vert
    elseif e_connects && w_connects
        return horiz
    elseif n_connects && e_connects
        return bend_ne
    elseif n_connects && w_connects
        return bend_nw
    elseif s_connects && e_connects
        return bend_se
    elseif s_connects && w_connects
        return bend_sw
    else
        error("No start pipe found")
    end
end

function bfs(arr_map)

    # a breadth-first search algorithm to find the shortest path
    # construct a graph to represent the nodes and edges
    # find the node that is furthest from the start

    start_pos = find_start(arr_map)
    dist = zeros(size(arr_map))
    connections = []
    current_pos = start_pos
    i = 1
    pipe_coords = [start_pos]
    while i <= length(pipe_coords)
        current_pos = pipe_coords[i]
        pipe = current_pos == start_pos ? infer_start_pipe(arr_map,start_pos) : arr_map[current_pos...]
        adjs = map(x->(x[1] + current_pos[1], x[2] + current_pos[2]), deltas[pipe])
        if !(current_pos in pipe_coords)
            push!(pipe_coords, current_pos)
        end
        for adj in adjs
            push!(connections, (current_pos, adj))
            if !(adj in pipe_coords)
                push!(pipe_coords, adj)
            end
        end
        i += 1
    end
    for c in connections
        if dist[c[2]...] != 0
            dist[c[2]...] = min(dist[c[2]...], dist[c[1]...] + 1)
        else
            dist[c[2]...] = dist[c[1]...] + 1
        end
    end
    return maximum(dist)
end

function sol1(input)
    pipe_map = build_map(input)
    return bfs(pipe_map)
end

function flood_fill(grid, x, y, fill_color)
    target_color = grid[x, y]
    if target_color == fill_color
        return grid
    end

    function dfs(x, y)
        if x < 1 || x > size(grid, 1) || y < 1 || y > size(grid, 2)
            return
        elseif grid[x, y] != target_color
            return
        end
        grid[x, y] = grid[x,y] != ground ? fill_color : grid[x,y]
        dfs(x+1, y)
        dfs(x-1, y)
        dfs(x, y+1)
        dfs(x, y-1)
    end

    dfs(x, y)
    return grid
end

function sol2(input)
    pipe_map = build_map(input)
    start_pos = find_start(pipe_map)
    inferred_pipe = infer_start_pipe(pipe_map, start_pos)
    pipe_map[start_pos...] = inferred_pipe
    # get coords of the pipe path
    coords = [start_pos]
    i = 1
    adj_pos = map(x->(x[1] + start_pos[1], x[2] + start_pos[2]), deltas[inferred_pipe])
    vertices = []
    if inferred_pipe in [bend_ne, bend_nw, bend_se, bend_sw]
        push!(vertices, start_pos)
    end
    while true
        if !(adj_pos[1] in coords)
            push!(coords, adj_pos[1])
        elseif !(adj_pos[2] in coords)
            push!(coords, adj_pos[2])
        else
            break
        end
        pos = coords[i+1]
        pipe = pipe_map[pos...]
        if pipe in [bend_ne, bend_nw, bend_se, bend_sw]
            push!(vertices, pos)
        end
        adj_pos = map(x->(x[1] + pos[1], x[2] + pos[2]), deltas[pipe])
        i+=1
    end
    A = 0
    for i in 1:length(vertices)-1
        (x1, y1) = vertices[i]
        (x2, y2) = vertices[i+1]
        A += (x1*y2 - x2*y1)
    end
    A+= (vertices[end][1] * vertices[1][2] - vertices[1][1] * vertices[end][2])
    pc = abs(A/2) - length(coords)/2 + 1
    return pc
end

example2 = """...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
..........."""

sol2(example2)


#calculate the determinant of the coord arr


function sense(c1, c2)
    return (c2[1] - c1[1]) / (c2[2] + c1[2])
end


# sol1(example2)
example3 =""".F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ..."""

sol2(example3)
example2 = """..F7.
.FJ|.
SJ.L7
|F--J
LJ..."""

input = read("input", String)

# sol1(input)
# test2 = build_map(example2)
# bfs(test2)

sol1(input)

sol2(input) 