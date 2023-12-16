using OrderedCollections;
function hash(s)
    n = 0
    for c in s
        # convert to ASCII
        if c == '\n'
            continue
        end
        n += Int(c)
        n *= 17
        n = n % 256
    end
    return n
end

function hashmap(lens_list)
    m = OrderedDict()
    for i in range(0, 255)
        m[i] = OrderedDict()
    end
    for lens in lens_list
        if '=' in lens
            # add lens to box
            (code, fl) = split(lens, "=")
            box = hash(code)
            m[box][code] = parse(Int,fl)
            v = join(" ",["[$k $v]" for (k, v) in m[box]])
        else
            # remove lens from box
            (code, fl) = split(lens, "-")
            box = hash(code)
            if haskey(m[box], code)
                delete!(m[box], code)
            end
        end
    end
    return m
end

function get_power(m)
    power = 0
    for (k, v) in m
        for (i, (code, fl)) in enumerate(v)
            power += (k+1) * i * fl
        end
    end
    return power
end

example = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

function sol1(input)
    s = split(input, ",")
    return sum(hash(x) for x in s)
end

function sol2(input)
    s = split(input, ",")
    m = hashmap(s)
    return get_power(m)
end
sol1(example) == 1320

input = read("2023/15/input", String)

@time sol1(input)


sol2(example)

@time sol2(input)