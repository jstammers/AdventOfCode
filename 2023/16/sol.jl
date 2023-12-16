function update(x,y,vx,vy,current)
    if current == '-'
        return vy == 0 ? [(x,y,0,-1), (x,y,0,1)] : [(x,y,vx,vy)]
    elseif current == '|'
        return vx == 0 ? [(x,y,-1,0), (x,y,1,0)] : [(x,y,vx,vy)]
    elseif current == '\\'
        if vy == 0 # U,D
            # U -> L, D -> R
            return vx > 0 ? [(x,y,0,1)] : [(x,y,0,-1)]
        else
            # L -> U, R -> D
            return vy > 0 ? [(x,y,1,0)] : [(x,y,-1,0)]
        end
    elseif current == '/'
        if vy == 0 # U,D
            # U -> R, D -> L
            return vx > 0 ? [(x,y,0,-1)] : [(x,y,0,1)]
        else
            # L -> D R -> U
            return vy > 0 ? [(x,y,-1,0)] : [(x,y,1,0)]
        end
    else
        return [(x,y,vx,vy)]
    end
end


function solve(maze, Lx, Ly, pos)
    energized = Set()
    init_points = Vector{Tuple{Int,Int,Int,Int}}()
    push!(init_points, pos)
    while length(init_points) > 0
        x,y,vx,vy = popfirst!(init_points)
        x,y = x+vx,y+vy
        if x < 1 || y < 1 || x > Lx || y > Ly || ((x,y,vx,vy) in energized)
            continue
        end
        push!(energized, (x,y,vx,vy))
        p1 = update(x,y,vx,vy,maze[x,y])
        append!(init_points, p1)
    end
    return length(Set([(x,y) for (x,y,vx,vy) in energized]))
end

example = raw""".|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|...."""

function solve_maze(maze, pos, dir)
    if dir == 'U'
        vx,vy = -1,0
    elseif dir == 'D'
        vx,vy = 1,0
    elseif dir == 'L'
        vx,vy = 0,-1
    elseif dir == 'R'
        vx,vy = 0,1
    end
    init_point = (pos[1], pos[2], vx, vy)
    return solve(maze, size(maze, 1), size(maze, 2), init_point)
    return sum(beam_array)
end

function sol1(input, dir='R', pos=(1, 0))
    maze = permutedims(stack(split(input, '\n')))
    return solve_maze(maze, pos, dir)
end

function sol2(input)
    num = []
    maze = permutedims(stack(split(input, '\n')))
    init_points = []
    for x in 1:size(maze, 1)
        push!(init_points, (x, 0, 0, 1))
        push!(init_points, (x, size(maze, 2) + 1, 0, -1))
    end
    for y in 1:size(maze, 2)
        push!(init_points, (0, y, 1, 0))
        push!(init_points, (size(maze, 1) + 1, y, -1, 0))
    end
    for init_point in init_points
        score = solve(maze, size(maze, 1), size(maze, 2), init_point)
        push!(num, score)
    end
    return maximum(num)
end


input = read("2023/16/input", String)[1:end-1]
@time sol1(input)
@time sol2(input)