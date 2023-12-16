ash = '.'
rocks = '#'

example = """#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#

"""

function find_reflection(s)
    # returns the index of the first reflection
    refs = []
    for i in 1:length(s)
        n = min(i, length(s) - i)
        l = s[i-n+1:i]
        r = s[i+1:i+n]
        if l == reverse(r) && length(l) > 0
            push!(refs, i)
        end
    end
    return Set(refs)
end

function find_reflection(s, smudge::Int)
    refs = []
    for i in 1:length(s)
        n = min(i, length(s) - i)
        l = s[i-n+1:i]
        r = s[i+1:i+n]
        diffs = []
        for (j, (a, b)) in enumerate(zip(l, reverse(r)))
            if a != b
                push!(diffs, i-n+j)
            end
        end
        if length(diffs) == smudge
            push!(refs,i)
        end
    end
    return refs
end

function row_reflections(string_arr)
    refs = [find_reflection(col) for col in eachcol(string_arr)]
    return intersect(refs...)
end

function row_reflections(string_arr, smudge::Int)
    refs = [find_reflection(col) for col in eachcol(string_arr)]
    refs_smudge = [find_reflection(col, smudge) for col in eachcol(string_arr)]
    return find_intersect(refs, refs_smudge)
end

function col_reflections(string_arr)
    # transpose the input
    refs = [find_reflection(col) for col in eachrow(string_arr)]
    return intersect(refs...)
end

function col_reflections(string_arr, smudge::Int)
    # transpose the input
    refs = [find_reflection(col) for col in eachrow(string_arr)]
    refs_smudge = [find_reflection(col, smudge) for col in eachrow(string_arr)]
    return find_intersect(refs, refs_smudge)
end

function find_intersect(reflections, changed_reflections)
    # find the elements that are in all but one set in reflections

    for i in 1:length(reflections)
        refs = copy(reflections)
        popat!(refs, i)
        common = intersect(refs...)
        if length(common) == 0
            continue
        else
            common2 = intersect(common, changed_reflections[i])
            if length(common2) == 0
                continue
            else
                return first(common2)
            end
        end
    end
    return []
end

t = """#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#."""

function sol1(input)
    total = 0
    for pattern in split(input, "\n\n")
        p = filter(x->length(x) > 0, split(pattern, '\n'))
        if length(p) == 0
            continue
        end
        pattern_arr = stack(p)
        r = row_reflections(pattern_arr)
        c = col_reflections(pattern_arr)
        if length(r) > 0
            r1 = first(r)
            total += r1
        elseif length(c) > 0
            c1 = first(c)
            total += c1 * 100
        end
    end
    return total
end

function sol2(input)
    total = 0
    for pattern in split(input, "\n\n")
        p = filter(x->length(x) > 0, split(pattern, '\n'))
        if length(p) == 0
            continue
        end
        pattern_arr = stack(p)
        r = row_reflections(pattern_arr, 1)
        c = col_reflections(pattern_arr, 1)
        if length(r) > 0
            r1 = first(r)
            total += r1
        elseif length(c) > 0
            c1 = first(c)
            total += c1 * 100
        end
    end
    return total
end

input = read("2023/13/input", String)

sol1(example) == 405
sol2(example) == 400
@time sol1(input)
@time sol2(input)