"""
--- Day 17: Conway Cubes ---
As your flight slowly drifts through the sky, the Elves at the Mythical Information Bureau at the North Pole contact you. They'd like some help debugging a malfunctioning experimental energy source aboard one of their super-secret imaging satellites.

The experimental energy source is based on cutting-edge technology: a set of Conway Cubes contained in a pocket dimension! When you hear it's having problems, you can't help but agree to take a look.

The pocket dimension contains an infinite 3-dimensional grid. At every integer 3-dimensional coordinate (x,y,z), there exists a single cube which is either active or inactive.

In the initial state of the pocket dimension, almost all cubes start inactive. The only exception to this is a small flat region of cubes (your puzzle input); the cubes in this region start in the specified active (#) or inactive (.) state.

The energy source then proceeds to boot up by executing six cycles.

Each cube only ever considers its neighbors: any of the 26 other cubes where any of their coordinates differ by at most 1. For example, given the cube at x=1,y=2,z=3, its neighbors include the cube at x=2,y=2,z=2, the cube at x=0,y=2,z=3, and so on.

During a cycle, all cubes simultaneously change their state according to the following rules:

If a cube is active and exactly 2 or 3 of its neighbors are also active, the cube remains active. Otherwise, the cube becomes inactive.
If a cube is inactive but exactly 3 of its neighbors are active, the cube becomes active. Otherwise, the cube remains inactive.
The engineers responsible for this experimental energy source would like you to simulate the pocket dimension and determine what the configuration of cubes should be at the end of the six-cycle boot process.

For example, consider the following initial state:

.#.
..#
###

Even though the pocket dimension is 3-dimensional, this initial state represents a small 2-dimensional slice of it. (In particular, this initial state defines a 3x3x1 region of the 3-dimensional space.)

Simulating a few cycles from this initial state produces the following configurations, where the result of each cycle is shown layer-by-layer at each given z coordinate (and the frame of view follows the active cells in each cycle):

After the full six-cycle boot process completes, 112 cubes are left in the active state.

Starting with your given initial configuration, simulate six cycles. How many cubes are left in the active state after the sixth cycle?
"""

t = """
.#.
..#
###
"""

using IterTools

ACTIVE = '#'
INACTIVE = '.'

function updatestate(cube,i,j,k)
    s = cube[i-1:i+1,j-1:j+1,k-1:k+1]
    n_a = sum([x==ACTIVE for x in s])
    state = cube[i,j,k]
    if (state == ACTIVE) & !(3 <= n_a <= 4)
        state = INACTIVE
    elseif (state == INACTIVE) & (n_a == 3)
        state = ACTIVE
    end
    return state
end


function simulate(cube)
    newcube = copy(cube)
    ni,nj,nk = size(cube)
    for i in 2:ni-1
        for j in 2:nj-1
            for k in 2:nk-1
                newcube[i,j,k] = updatestate(cube,i,j,k)
            end
        end
    end
    return newcube
end


s=fill(INACTIVE,101,101,101);
s[50,51,51] = ACTIVE
s[51,52,51] = ACTIVE
s[52,50:52,51] .= ACTIVE

for i in 1:6
    s = simulate(s)
end

sum([x == ACTIVE for x in s]) 


function parsecells(string)
    reduce(vcat, permutedims.(collect.(split(string))))
end

cells = parsecells(read("data/q17.txt", String));

ndims = size(cells)[1]

s=fill(INACTIVE,31,31,31);

i = 16
sub = i-Int(ndims/2):i+Int(ndims/2)-1
s[sub,sub,i] = cells

for i in 1:6
    s = simulate(s)
end

sum([x == ACTIVE for x in s]) == 391


"""
--- Part Two ---
For some reason, your simulated results don't match what the experimental energy source engineers expected. Apparently, the pocket dimension actually has four spatial dimensions, not three.

The pocket dimension contains an infinite 4-dimensional grid. At every integer 4-dimensional coordinate (x,y,z,w), there exists a single cube (really, a hypercube) which is still either active or inactive.

Each cube only ever considers its neighbors: any of the 80 other cubes where any of their coordinates differ by at most 1. For example, given the cube at x=1,y=2,z=3,w=4, its neighbors include the cube at x=2,y=2,z=3,w=3, the cube at x=0,y=2,z=3,w=4, and so on.

The initial state of the pocket dimension still consists of a small flat region of cubes. Furthermore, the same rules for cycle updating still apply: during each cycle, consider the number of active neighbors of each cube.

For example, consider the same initial state as in the example above. Even though the pocket dimension is 4-dimensional, this initial state represents a small 2-dimensional slice of it. (In particular, this initial state defines a 3x3x1x1 region of the 4-dimensional space.)

Simulating a few cycles from this initial state produces the following configurations, where the result of each cycle is shown layer-by-layer at each given z and w coordinate:
"""

function updatestate(cube,i,j,k,l)
    s = cube[i-1:i+1,j-1:j+1,k-1:k+1, l-1:l+1]
    n_a = sum([x==ACTIVE for x in s])
    state = cube[i,j,k,l]
    if (state == ACTIVE) & !(3 <= n_a <= 4)
        state = INACTIVE
    elseif (state == INACTIVE) & (n_a == 3)
        state = ACTIVE
    end
    return state
end


function simulate(cube)
    newcube = copy(cube)
    ni,nj,nk,nl = size(cube)
    for i in 2:ni-1
        for j in 2:nj-1
            for k in 2:nk-1
                for l in 2:nl-1
                    newcube[i,j,k,l] = updatestate(cube,i,j,k,l)
                end
            end
        end
    end
    return newcube
end

s=fill(INACTIVE,31,31,31,31);
i = 16
sub = i-Int(ndims/2):i+Int(ndims/2)-1
s[sub,sub,i,i] = cells

for i in 1:6
    s = simulate(s)
end

sum([x == ACTIVE for x in s]) 