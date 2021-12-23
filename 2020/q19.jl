"""
--- Day 19: Monster Messages ---
You land in an airport surrounded by dense forest. As you walk to your high-speed train, the Elves at the Mythical Information Bureau contact you again. They think their satellite has collected an image of a sea monster! Unfortunately, the connection to the satellite is having problems, and many of the messages sent back from the satellite have been corrupted.

They sent you a list of the rules valid messages should obey and a list of received messages they've collected so far (your puzzle input).

The rules for valid messages (the top part of your puzzle input) are numbered and build upon each other. For example:

0: 1 2
1: "a"
2: 1 3 | 3 1
3: "b"
Some rules, like 3: "b", simply match a single character (in this case, b).

The remaining rules list the sub-rules that must be followed; for example, the rule 0: 1 2 means that to match rule 0, the text being checked must match rule 1, and the text after the part that matched rule 1 must then match rule 2.

Some of the rules have multiple lists of sub-rules separated by a pipe (|). This means that at least one list of sub-rules must match. (The ones that match might be different each time the rule is encountered.) For example, the rule 2: 1 3 | 3 1 means that to match rule 2, the text being checked must match rule 1 followed by rule 3 or it must match rule 3 followed by rule 1.

Fortunately, there are no loops in the rules, so the list of possible matches will be finite. Since rule 1 matches a and rule 3 matches b, rule 2 matches either ab or ba. Therefore, rule 0 matches aab or aba.

Here's a more interesting example:

0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"
Here, because rule 4 matches a and rule 5 matches b, rule 2 matches two letters that are the same (aa or bb), and rule 3 matches two letters that are different (ab or ba).

Since rule 1 matches rules 2 and 3 once each in either order, it must match two pairs of letters, one pair with matching letters and one pair with different letters. This leaves eight possibilities: aaab, aaba, bbab, bbba, abaa, abbb, baaa, or babb.

Rule 0, therefore, matches a (rule 4), then any of the eight options from rule 1, then b (rule 5): aaaabb, aaabab, abbabb, abbbab, aabaab, aabbbb, abaaab, or ababbb.

The received messages (the bottom part of your puzzle input) need to be checked against the rules so you can determine which are valid and which are corrupted. Including the rules and the messages together, this might look like:

0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

ababbb
bababa
abbbab
aaabbb
aaaabbb
Your goal is to determine the number of messages that completely match rule 0. In the above example, ababbb and abbbab match, but bababa, aaabbb, and aaaabbb do not, producing the answer 2. The whole message must match all of rule 0; there can't be extra unmatched characters in the message. (For example, aaaabbb might appear to match rule 0 above, but it has an extra unmatched b on the end.)

How many messages completely match rule 0?
"""

t = """
0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"
6: 5 5
"""

using Base.Iterators
using Test
using Memoize

function parserules(line)
    key,vals = split(line,": ")
    vals = replace(vals,"\"" => "")
    return key, vals
end

function ruleset(t)
    d = Dict()
    for (x,y) in map(parserules, eachline(IOBuffer(t)))
        d[x] = y
    end
return d
end

@memoize function reg(x::AbstractString, d::Dict)
    s = []
    if x in keys(d)
        x = d[x]
    end
    if x in ["a", "b"]
        return x
    elseif !occursin("|", x)
        s = join(map(y->reg(y,d), split(x, " ")))
    else
        t = split(x, " | ")
        regs = map(z->reg(z,d),t)
        s = join(regs, "|")
        s = "($s)"
    end
return s
end

function matchzero(string, zeroset)
    c = 0
    z = Regex(zeroset)
    for line in split(string, "\n")
        if !isnothing(match(z, line))
            c+=1
        end
    end
    return c
end 

function countnewmatches(rulestring, charstring, i::Int)
    rules = ruleset(rulestring)
    if i >= 2
        rules["8"] = h("42", i)
        rules["11"] = h("42", "31", i)
    end
    z = reg("0",rules)
    z1 = "^$z\$"
    c2 = matchzero(charstring, z1)
    return c2
end

function h(a,b,n)
    s = [repeat("$a ",x)*repeat("$b ", x) for x in 1:n]
    return rstrip(join(s, "| "))
end

function h(a,n)
    s = [repeat("$a ",x) for x in 1:n]
    return rstrip(join(s, "| "))
end



@test h("8",2) == "8 | 8 8"
@test h("8",3) == "8 | 8 8 | 8 8 8"
@test h("42", "31", 2) == "42 31 | 42 42 31 31"

data = split(read("data/q19.txt", String), "\n\n");

r = ruleset(data[1]);


@test reg("48",r) == "b"

@test reg("48 48",r) == "bb"

@test reg("48 48 | 41 48",r ) == "(bb|ab)"


rules = """
42: 9 14 | 10 1
9: 14 27 | 1 26
10: 23 14 | 28 1
1: "a"
11: 42 31
5: 1 14 | 15 1
19: 14 1 | 14 14
12: 24 14 | 19 1
16: 15 1 | 14 14
31: 14 17 | 1 13
6: 14 14 | 1 14
2: 1 24 | 14 4
0: 8 11
13: 14 3 | 1 12
15: 1 | 14
17: 14 2 | 1 7
23: 25 1 | 22 14
28: 16 1
4: 1 1
20: 14 14 | 1 15
3: 5 14 | 16 1
27: 1 6 | 14 18
14: "b"
21: 14 1 | 1 14
25: 1 1 | 1 14
22: 14 14
8: 42
26: 14 22 | 1 20
18: 15 15
7: 14 5 | 1 21
24: 14 1
"""


lists = """
abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
bbabbbbaabaabba
babbbbaabbbbbabbbbbbaabaaabaaa
aaabbbbbbaaaabaababaabababbabaaabbababababaaa
bbbbbbbaaaabbbbaaabbabaaa
bbbababbbbaaaaaaaabbababaaababaabab
ababaaaaaabaaab
ababaaaaabbbaba
baabbaaaabbaaaababbaababb
abbbbabbbbaaaababbbbbbaaaababb
aaaaabbaabaaaaababaa
aaaabbaaaabbaaa
aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
babaaabbbaaabaababbaabababaaab
aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
"""

re = Regex("((ab)(?1)?(cd))")
match(re, "abababcdcdcd")


@test countnewmatches(rules, lists, 1) == 3
@test countnewmatches(rules, lists, 4) == 12

countnewmatches(data[1],data[2],3)
