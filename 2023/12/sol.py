import functools

def parse(line):
    s, groups = line.strip().split(" ")
    lookup = {"#": 2, "?": 1, ".": 0}
    return tuple(lookup[char] for char in s), tuple(int(g) for g in groups.split(","))

with open("input") as f:
    data = [parse(x) for x in f]


def match_beginning(data, length):
    return all(x > 0 for x in data[:length]) and (
        (len(data) == length) or data[length] < 2
    )


@functools.cache
def count(data, blocks):
    l2 = {2: '#', 1: '?', 0: '.'}
    total = sum(blocks)
    minimum = sum(x == 2 for x in data)
    maximum = sum(x > 0 for x in data)
    s = ''.join(l2[x] for x in data)
    print("s = {}, c = {}, min = {}, max = {}, total = {}".format(s, blocks, minimum, maximum, total))
    if minimum > total or maximum < total:
        return 0
    if total == 0:
        return 1
    if data[0] == 0:
        return count(data[1:], blocks)
    if data[0] == 2:
        l = blocks[0]
        if match_beginning(data, l):
            if l == len(data):
                return 1
            return count(data[l + 1:], blocks[1:])
        return 0
    return count(data[1:], blocks) + count((2,) + data[1:], blocks)


# counts = [count(*line) for line in data]

# with open("output1", "w") as f:
#     f.write("\n".join(str(x) for x in counts))

# print(sum(count(*line) for line in data))
d = (1,)
b = ()

test, counts = parse("????#.?.?#?? 3,1")
print(count(test, counts))


s = "#.?.?#??"
c = "3,1"
lookup = {"#": 2, "?": 1, ".": 0}
print(match_beginning([lookup[x] for x in s], 3))