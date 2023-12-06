#read lines from an input file
function getdigit(s, re)
    matches = collect(eachmatch(re, s, overlap=true))
    first_match = matches[1].match
    last_match = matches[end].match
    if first_match in keys(digit_map)
        d1 = digit_map[first_match]
    else
        d1 = first_match
    end
    if last_match in keys(digit_map)
        d2 = digit_map[last_match]
    else
        d2 = last_match
    end
    d = parse(Int64, join([d1, d2]))
    return d
end

#%%
lines = readlines("01/input")

tot1 = 0
re1 = Regex("\\d")
for line in lines
    d = getdigit(line, re1)
    tot1 += d
end
println(tot1)

re2 = Regex("one|two|three|four|five|six|seven|eight|nine|[0-9]")

examp = "two1nine"

digit_map = Dict(
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9",
    # "zero" => "0"
)


tot2 = 0
results = Array{String, 1}()
for line in lines
    d = getdigit(line, re2)
    tot2 += d
    s = line * " => " * string(d)
end
println(tot2)

examps = ["two1nine",
"eightwothree",
"abcone2threexyz","xtwone3four",
"4nineeightseven2",
"zoneight234",
"7pqrstsixteen"]

s = 0
for examp in examps
    d = getdigit(examp, re2)
    s += d
    println(d)
end
println(s)