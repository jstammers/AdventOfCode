using Test
using Memoize
d1 = sort([16,10,15,5,1,11,7,19,6,12,4]);
d2 = [1, 2, 3, 4, 7, 8, 9, 10, 11, 14, 17, 18, 19, 20, 23,24, 25, 28, 31,
32, 33, 34, 35, 38, 39, 42, 45, 46, 47, 48, 49];

@memoize function func(i, adapters)
    if (i == length(adapters))
        return 1
    else
        ans = 0
        for j in i+1:length(adapters)
            # println(adapters[j:end])
            if (adapters[j] - adapters[i]) <= 3
                ans += func(j, adapters)
            end
        end
        return ans
    end
end

# 19208

@test func(1,d1) == 8
#@test func(1,d2) == 19208

data = sort(map(x -> parse(Int, x), eachline(open("data/q10.txt"))));

s = func(1, data)