"""
--- Day 20: Jurassic Jigsaw ---
The high-speed train leaves the forest and quickly carries you south. You can even see a desert in the distance! Since you have some spare time, you might as well see if there was anything interesting in the image the Mythical Information Bureau satellite captured.

After decoding the satellite messages, you discover that the data actually contains many small images created by the satellite's camera array. The camera array consists of many cameras; rather than produce a single square image, they produce many smaller square image tiles that need to be reassembled back into a single image.

Each camera in the camera array returns a single monochrome image tile with a random unique ID number. The tiles (your puzzle input) arrived in a random order.

Worse yet, the camera array appears to be malfunctioning: each image tile has been rotated and flipped to a random orientation. Your first task is to reassemble the original image by orienting the tiles so they fit together.

To show how the tiles should be reassembled, each tile's image data includes a border that should line up exactly with its adjacent tiles. All tiles have this border, and the border lines up exactly when the tiles are both oriented correctly. Tiles at the edge of the image also have this border, but the outermost edges won't line up with any other tiles.

For example, suppose you have the following nine tiles:

Tile 2311:
..##.#..#.
##..#.....
#...##..#.
####.#...#
##.##.###.
##...#.###
.#.#.#..##
..#....#..
###...#.#.
..###..###

Tile 1951:
#.##...##.
#.####...#
.....#..##
#...######
.##.#....#
.###.#####
###.##.##.
.###....#.
..#.#..#.#
#...##.#..

Tile 1171:
####...##.
#..##.#..#
##.#..#.#.
.###.####.
..###.####
.##....##.
.#...####.
#.##.####.
####..#...
.....##...

Tile 1427:
###.##.#..
.#..#.##..
.#.##.#..#
#.#.#.##.#
....#...##
...##..##.
...#.#####
.#.####.#.
..#..###.#
..##.#..#.

Tile 1489:
##.#.#....
..##...#..
.##..##...
..#...#...
#####...#.
#..#.#.#.#
...#.#.#..
##.#...##.
..##.##.##
###.##.#..

Tile 2473:
#....####.
#..#.##...
#.##..#...
######.#.#
.#...#.#.#
.#########
.###.#..#.
########.#
##...##.#.
..###.#.#.

Tile 2971:
..#.#....#
#...###...
#.#.###...
##.##..#..
.#####..##
.#..####.#
#..#.#..#.
..####.###
..#.#.###.
...#.#.#.#

Tile 2729:
...#.#.#.#
####.#....
..#.#.....
....#..#.#
.##..##.#.
.#.####...
####.#.#..
##.####...
##..#.##..
#.##...##.

Tile 3079:
#.#.#####.
.#..######
..#.......
######....
####.#..#.
.#...#.##.
#.#####.##
..#.###...
..#.......
..#.###...
By rotating, flipping, and rearranging them, you can find a square arrangement that causes all adjacent borders to line up:

#...##.#.. ..###..### #.#.#####.
..#.#..#.# ###...#.#. .#..######
.###....#. ..#....#.. ..#.......
###.##.##. .#.#.#..## ######....
.###.##### ##...#.### ####.#..#.
.##.#....# ##.##.###. .#...#.##.
#...###### ####.#...# #.#####.##
.....#..## #...##..#. ..#.###...
#.####...# ##..#..... ..#.......
#.##...##. ..##.#..#. ..#.###...

#.##...##. ..##.#..#. ..#.###...
##..#.##.. ..#..###.# ##.##....#
##.####... .#.####.#. ..#.###..#
####.#.#.. ...#.##### ###.#..###
.#.####... ...##..##. .######.##
.##..##.#. ....#...## #.#.#.#...
....#..#.# #.#.#.##.# #.###.###.
..#.#..... .#.##.#..# #.###.##..
####.#.... .#..#.##.. .######...
...#.#.#.# ###.##.#.. .##...####

...#.#.#.# ###.##.#.. .##...####
..#.#.###. ..##.##.## #..#.##..#
..####.### ##.#...##. .#.#..#.##
#..#.#..#. ...#.#.#.. .####.###.
.#..####.# #..#.#.#.# ####.###..
.#####..## #####...#. .##....##.
##.##..#.. ..#...#... .####...#.
#.#.###... .##..##... .####.##.#
#...###... ..##...#.. ...#..####
..#.#....# ##.#.#.... ...##.....
For reference, the IDs of the above tiles are:

1951    2311    3079
2729    1427    2473
2971    1489    1171
To check that you've assembled the image correctly, multiply the IDs of the four corner tiles together. If you do this with the assembled tiles from the example above, you get 1951 * 3079 * 2971 * 1171 = 20899048083289.

Assemble the tiles into an image. What do you get if you multiply togeth
"""

using Rotations
using DelimitedFiles
using IterTools
using Test
t ="""
..##.#..#.
##..#.....
#...##..#.
####.#...#
##.##.###.
##...#.###
.#.#.#..##
..#....#..
###...#.#.
..###..###
"""

NULL = '-'
struct Image
    id:: Int
    pixels::Array{Char,2}
end

function toarray(t)
    a = map(Vector{Char},readdlm(IOBuffer(t),'\n'))
    return hcat(a...)
end

function permute(a::Array{Char,2})
    return a, rotr90(a), rot180(a), rotl90(a)
end

function flip(a::Array{Char, 2})
    return reverse(a, dims=2)
end

function allperms(img::Image)
    a = img.pixels
    return [Image(img.id,x) for x in (permute(a)...,permute(flip(a))...)]
end

function stitch(imgarray::Array{Image, 2})
    pixels = [img.pixels for img in imgarray]
    n = Int(sqrt(length(pixels)))
    return hvcat((n,n, n),pixels...)
end

function isaligned(imgarray::Array{Image, 2})
    img = stitch(imgarray)
    stride = size(imgarray[1].pixels)[1]
    strides = stride:stride:size(img)[1]-stride
    for stride in strides
        r1 = img[:,stride]
        r2 = img[:,stride+1]
        if !isaligned(r1,r2)
            return false
        end
        c1 = img[stride, :]
        c2 = img[stride+1,:]
        if !isaligned(c1,c2)
            return false
        end
    end
    return true
end

function isaligned(v1::Array{Char,1}, v2::Array{Char,1})
    ix = (v1 .== NULL) .& (v2 .== NULL)
    return all(v1[ix] .== v2[ix])
end

function fit(images::Array{Image,1}, imgarray::Array{Image, 2}, i)
    if length(images) == 0
        return imgarray
    end

    for (ix,img) in enumerate(images)
        imgs = copy(images)
        arr = popat!(imgs, ix)
        for perm in allperms(arr)
            imgarray[i] = perm
            if isaligned(imgarray)
                if all(stitch(imgarray) .== NULL)
                    println([x.id for x in imgarray])
                    return imgarray
                else
                    imgarray = fit(imgs, imgarray, i+1)
                end
            else
                imgarray[i] = nullimg
            end
        end
    end
    return imgarray
end

function load(file::String)
    data = read(file, String)
    tiles = split(data, "\n\n")
    imgarray::Array{Image,1} = []
    for tile in tiles
        num = parse(Int, tile[6:9])
        arr = toarray(tile[12:end])
        push!(imgarray, Image(num, arr))
    end
    return imgarray
end

images = load("data/q20_example.txt");
nullimg = Image(0,fill(NULL, (10,10)));

imagearray = fill(nullimg, (3,3));
a = fit(images, imagearray, 1);

ix = [x.id for x in a]
