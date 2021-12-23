
FLOOR = '.'
EMPTY = 'L'
OCCUPIED = '#'

function iter_seats(arr,i,j, x_op, y_op)
    s = 0
    if x_op == +
        i_iter = i+1:size(arr)[1]
    elseif x_op == -
        i_iter = i-1:-1:1
    end

    if y_op == +
        j_iter = j+1:size(arr)[2]
    elseif y_op == -
        j_iter = j-1:-1:1
    end

    if x_op == 0
        i_iter = fill(i,length(j_iter))
    end

    if y_op == 0
        j_iter = fill(j, length(i_iter))
    end

    for (i1,j1) in Iterators.zip(i_iter, j_iter)
        v = arr[i1,j1]
        if v == OCCUPIED
            return 1
        elseif v == EMPTY
            return 0
        end
    end
    return 0
end

function adjacentSeats(arr,i, j)
    ops = [(+,+), (+,-), (-,-), (-,+),(+,0), (-,0), (0,+), (0,-)]
    s = sum(map(x -> iter_seats(arr,i,j,x[1],x[2]),ops))    
return s
end

function seatState(arr, i,j)
    num_seats = adjacentSeats(arr,i,j)
    if (arr[i,j] == EMPTY) & (num_seats == 0)
        return OCCUPIED
    elseif (num_seats >= 5) & (arr[i,j] == OCCUPIED)
        return EMPTY
    else
        return arr[i,j]
    end
end

function stringArray(a)
    s = split(a, "\n")
    n = length(s[1])
    s = ["$FLOOR$t$FLOOR" for t in s]
    v = repeat(FLOOR, n+2)
    push!(s,v)
    pushfirst!(s,v)
    n2 = length(s[1])
    n1 = length(s)
    A = Matrix{Char}(undef,n1,n2) # preallocating the result
    for i in 1:length(s) # looping over all strings
        for (j, c) in enumerate(s[i]) # looping over all chars in a string
            A[i, j] = c
        end
    end
    return A
end


i1 = """
.......#.
...#.....
.#.......
.........
..#L....#
....#....
.........
#........
...#....."""
d2 = stringArray(i1);
adjacentSeats(d2,6,5)