function parseline(line)
    game_re = r"Game (\d+):"
    game_match = match(game_re, line)
    games = split(line, ":")[2]
    game = parse(Int64, game_match.captures[1])

    sets = split(games, ";")
    
    return game, sets
end

function countcolors(set)
    r_count = match(r"(\d+) red", set)
    g_count = match(r"(\d+) green", set)
    b_count = match(r"(\d+) blue", set)

    if isnothing(r_count)
        r_count = 0
    else
        r_count = parse(Int64,r_count.captures[1])
    end

    if isnothing(g_count)
        g_count = 0
    else
        g_count = parse(Int64, g_count.captures[1])
    end

    if isnothing(b_count)
        b_count = 0
    else
        b_count = parse(Int64, b_count.captures[1])
    end
    return r_count, g_count, b_count
end


rmax = 12
gmax = 13
bmax = 14

tot1 = 0
for line in eachline("02/input")
    game, sets = parseline(line)
    possible = true
    for s in sets
        r_count, g_count, b_count = countcolors(s)
        if r_count > rmax || g_count > gmax || b_count > bmax
            possible = false
        end
    end
    if possible
        tot1 += game
    end
end
println(tot1)


function mincubes(sets)
    rcounts = Vector{Int64}()
    gcounts = Vector{Int64}()
    bcounts = Vector{Int64}()
    for s in sets
        r_count, g_count, b_count = countcolors(s)
        push!(rcounts, r_count)
        push!(gcounts, g_count)
        push!(bcounts, b_count)
    end
    return maximum(rcounts), maximum(gcounts), maximum(bcounts)
end

tot2 = 0
for line in eachline("02/input")
    game, sets = parseline(line)
    rmax, gmax, bmax = mincubes(sets)
    power = rmax * gmax * bmax
    tot2 += power
end
println(tot2)


