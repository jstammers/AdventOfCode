example = """Time:      7  15   30
Distance:  9  40  200"""

acc = 1

# s = u*t + 0.5 * a * t^2

# hold button for t0 seconds, boat accelerates to u = acc * t0
# boat travels s = u * t1
# require t0 + t1 < tr
# s = ta * (tr - ta)
# solve ta^2 - tr * ta + s > 0

function parse_input(input)
    time = match(r"Time:      (\d+)  (\d+)   (\d+) ", input).captures
    distance = match(r"Distance:  (\d+)  (\d+)  (\d+)", input).captures
    return (time, distance)
end


function total_distance(accel_time, race_time)
    return 1 * accel_time * (race_time - accel_time)
end

function time_bounds(race_time, race_distance)
    # solves the quadratic equation
    # t^2 - race_time * t + race_distance = 0
    a = 1
    b = - race_time
    c = race_distance
    t1 = (-b + sqrt(b^2 - 4 * a * c)) / (2 * a)
    t2 = (-b - sqrt(b^2 - 4 * a * c)) / (2 * a)
    # println(t1, " ", t2)
    # println(ceil(t1), " ", floor(t1), " ", t1)
    # println(ceil(t2), " ", floor(t2), " ", t2)
    t1 = ceil(t1) == floor(t1) ? Int(t1 - 1) + 1 : Int(ceil(t1))
    t2 = ceil(t2) == floor(t2) ? Int(t2 + 1) : Int(ceil(t2))
    return t1 - t2
end
time_bounds(7, 9)
time_bounds(15, 40)
time_bounds(30, 200)

input = """Time: 59 68     82     74
Distance:   543   1020   1664   1022"""


function sol1(input)
    s = 1
    times = [59, 68, 82, 74]
    distances = [543, 1020, 1664, 1022]
    for (time, distance) in zip(times, distances)
        s *= time_bounds(Int(time), Int(distance))
    end
    return s
end

sol1(input)

time_bounds(71530, 940200)
time_bounds(59688274, 543102016641022)