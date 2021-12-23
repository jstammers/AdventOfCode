data = readlines("data/q13.txt")
timestamp = parse(Int,data[1])
buses = [parse(Int,x) for x in split(data[2],",") if x != "x"];
(buses .* map(x -> ceil(timestamp/x),buses)) .- timestamp

function earliestTimestamp(busList)
    bus_dict = Dict()
    for (i,b) in enumerate(busList)
        if b == 'x'
            continue
        else
            bus_dict[i] = parse(Int,b)
        end
    end
end

