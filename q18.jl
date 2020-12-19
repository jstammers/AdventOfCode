"""
--- Day 18: Operation Order ---
As you look out the window and notice a heavily-forested continent slowly appear over the horizon, you are interrupted by the child sitting next to you. They're curious if you could help them with their math homework.

Unfortunately, it seems like this "math" follows different rules than you remember.

The homework (your puzzle input) consists of a series of expressions that consist of addition (+), multiplication (*), and parentheses ((...)). Just like normal math, parentheses indicate that the expression inside must be evaluated before it can be used by the surrounding expression. Addition still finds the sum of the numbers on both sides of the operator, and multiplication still finds the product.

However, the rules of operator precedence have changed. Rather than evaluating multiplication before addition, the operators have the same precedence, and are evaluated left-to-right regardless of the order in which they appear.

For example, the steps to evaluate the expression 1 + 2 * 3 + 4 * 5 + 6 are as follows:

1 + 2 * 3 + 4 * 5 + 6
  3   * 3 + 4 * 5 + 6
      9   + 4 * 5 + 6
         13   * 5 + 6
             65   + 6
                 71
Parentheses can override this order; for example, here is what happens if parentheses are added to form 1 + (2 * 3) + (4 * (5 + 6)):

1 + (2 * 3) + (4 * (5 + 6))
1 +    6    + (4 * (5 + 6))
     7      + (4 * (5 + 6))
     7      + (4 *   11   )
     7      +     44
            51
Here are a few more examples:

2 * 3 + (4 * 5) becomes 26.
5 + (8 * 3 + 9 + 3 * 4 * 3) becomes 437.
5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4)) becomes 12240.
((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2 becomes 13632.
Before you can help with the homework, you need to understand it yourself. Evaluate the expression on each line of the homework; what is the sum of the resulting values?
"""


using Test

function leftapply(string)
    expr = exprstring(string)
    return eval(Meta.parse(expr))
end

function exprstring(string)
    ops = []
    vals = []
    while occursin("(", string)
        substring = match(r"\(([^()]+)\)", string)
        s = exprstring(substring.match[2:end-1])
        c = Vector{Char}(string)
        i = c[begin:substring.offset-1]
        j = c[substring.offset+length(substring.match):end]
        string = join([String(i), "$s", String(j)])
    end
    for v in split(string, " ")
        if occursin(v,"+*")
            push!(ops,v)
        else
            push!(vals, parse(Int, v))
        end
    end
    s = "$(vals[1])"
    for (i,op) in enumerate(ops)
        s = "$op($s, $(vals[i+1]))"
    end
    return eval(Meta.parse(s))
end

# @test exprstring("1 + 2") == "+(1, 2)"


# @test exprstring("1 + 2 + 3") == "+(+(1, 2), 3)"

# exprstring("2 * 3 + (4 * 5)") == "+(*(2, 3), *(4, 5))"

# @test exprstring("1 + 2") == 3

# @test exprstring("1 + 2 * 3 + 4 * 5 + 6") == 71

# @test exprstring("2 * 3 + (4 * 5)") == 26

# @test exprstring("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 437

# @test exprstring("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 12240

# @test exprstring("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 13632

# s = sum([exprstring(x) for x in eachline("data/q18.txt")])

"""
--- Part Two ---
You manage to answer the child's questions and they finish part 1 of their homework, but get stuck when they reach the next section: advanced math.

Now, addition and multiplication have different precedence levels, but they're not the ones you're familiar with. Instead, addition is evaluated before multiplication.

For example, the steps to evaluate the expression 1 + 2 * 3 + 4 * 5 + 6 are now as follows:

1 + 2 * 3 + 4 * 5 + 6
  3   * 3 + 4 * 5 + 6
  3   *   7   * 5 + 6
  3   *   7   *  11
     21       *  11
         231
Here are the other examples from above:

1 + (2 * 3) + (4 * (5 + 6)) still becomes 51.
2 * 3 + (4 * 5) becomes 46.
5 + (8 * 3 + 9 + 3 * 4 * 3) becomes 1445.
5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4)) becomes 669060.
((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2 becomes 23340.
What do you get if you add up the results of evaluating the homework problems using these new rules?
"""

function ⊕(x,y) return x*y end
function ⊙(x,y) return x+y end

function expr2(string)
    string =replace(string, "*"=>"⊕")
    string = replace(string, "+"=>"⊙")
    m = Meta.parse(string)
    return eval(m)
end

function swap_ops(op, opr1, opr2)
    op2 = op == :+ ? :* : :+
    retexpr = Expr(:call, op2,opr1, opr2)
    return retexpr 
end

function swap_rec(m:: Expr)
    filter!(m.args) do e
        if isa(e, Expr)
            (e::Expr).args === swap_ops(e.args)
        swap_rec(e)
        end
    end
    return m
end

#     t =[]
#     if length(m.args) == 3
#         return swap_ops(m.args...)
#     else
#         for (i,a) in enumerate(m.args)
#             if typeof(a) == Expr
#                 push!(t,swap_ops(a.args...))
#             end
#         end
#     end
#     return t
# end



expr2("1 + (2 * 3) + (4 * (5 + 6))") == 51

@test expr2("2 * 3 + (4 * 5)") == 46 

@test expr2("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 1445

@test expr2("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 669060

@test expr2("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 23340

s = sum([expr2(x) for x in eachline("data/q18.txt")])