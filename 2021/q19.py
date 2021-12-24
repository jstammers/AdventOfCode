import numpy as np
import pandas as pd
from scipy import stats

class Scanner:
    def __init__(self, input):
        self.arr = np.array([np.fromstring(x, sep=",") for x in input.splitlines()]).astype(int)
        d = []
        if self.arr.shape[1] == 2:
            for x,y in self.arr:
                d.append({'x':x,'y':y,'o':'B'})
            d.append({'x':0,'y':0,'o':'S'})
        elif self.arr.shape[1] == 3:
            for x,y,z in self.arr:
                d.append({'x':x,'y':y,'z':z,'o':'B'})
            d.append({'x':0,'y':0,'z':0, 'o':'S'})
        self.df = pd.DataFrame(d)
        # self.v = self.vision()

        self.o = self.orients()

    def vision(self):
        use_z = "z" in self.df.columns
        if use_z:
            cols = ['x','y','z']
        else:
            cols = ['x','y']
        d = self.df.copy()
        d[cols] = d[cols] - d[cols].min()
        s = d[cols].max()
        v = np.full(shape=s+1, fill_value='.')
        for i,row in d.iterrows():
            x = row["x"]
            y = row["y"]
            o = row["o"]
            if use_z:
                z = row["z"]
                v[x,y,z] = o
            else:
                v[x,y] = o

        return np.flip(v,0)

    def orients(self):
        ndim = self.arr.shape[1]
        o = []
        for i in range(ndim):
            ax = np.sort(self.arr[:,i])
            o.append(ax)
            o.append(np.sort(-ax))
        return np.array(o)

    def find_translations(self, other: "Scanner", m=12):

        diffs = np.subtract.outer(self.o, other.o.T)
        i = 0
        pos = None
        while i <= np.max([diffs.shape[0] - m,0]):
            diags = np.diagonal(diffs, i, axis1=1, axis2=2)
            modes = stats.mode(diags, axis=2)
            matches = modes.count >= m
            if matches.any():
                pos = matches.nonzero()
                break
            else:
                i += 1
        if pos is None:
            return None
        # diffs = np.diff(self.o, axis=1)[:,np.newaxis] - np.diff(other.o, axis=1)
        #
        # locs = np.sum(diffs == 0, axis=-1) >= m - 1
        # pos = locs.nonzero()
        # if len(pos[0]) == 0:
        #     return None
        i = self.o[pos[0]]
        j = other.o[pos[1]]
        tr = (i - j)[:,0][[0,2,4]]
        arr = other.reorient(pos)
        return arr.T + tr

    def reorient(self, coords:np.array):
        """reorient the scanner to the given coordinates"""
        new_x = np.argwhere(coords[1] == 0)[0]
        new_y = np.argwhere(coords[1] == 2)[0]
        new_z = np.argwhere(coords[1] == 4)[0]
        m  = self.o[np.array([new_x, new_y, new_z]).flatten()]
        return m

    # def __repr__(self):
    # if self.arr.ndim == 2:
    #     return "\n".join(["".join(x) for x in self.v])

def find_translation(s,t,m=12):
    """finds a translation for which s and t have at least m matches"""
    m = len(s)
    diffs = np.diff(s, axis=1)[:,np.newaxis] - np.diff(t, axis=1)
    locs = np.sum(diffs == 0, axis=-1) >= m - 1
    pos = locs.nonzero()
    return pos

def trans_2(x,y, m=12):
    if x.shape[0] > y.shape[0]:
        r = x
        l = y
    else:
        r = y
        l = x
    v = r.max() - l.max()
    if v > 0:
        i = np.arange(v+1)
    else:
        i = np.arange(0,v-1,-1)
    l1 = l[:,np.newaxis] + i
    return l1
def find_rotation(s: np.array, t: np.array, m=12):
    """finds the rotation plane for which the elements of s and t have at least m matches"""
    l = []
    for i,c1 in enumerate(['x','-x','y','-y','z','-z']):
        for j, c2 in enumerate(['x','-x','y','-y','z','-z']):
            tr = find_translation(s[i], t[j], m)
            if len(tr) > 0:
                l.append((c1,c2,tr))
    return l

def parse_string(s):
    l = []
    scanners = []
    for line in s.splitlines():
        if line == "" or line[0] == "\n":
            i = "\n".join(l)
            scanners.append(Scanner(i))
            l.clear()
        elif "---" in line:
            continue
        else:
            l.append(line)
    i = "\n".join(l)
    scanners.append(Scanner(i))
    return scanners


s = np.array([[1,2,3],[3,10,1],[10,2020,1],[201201,2,1],[20304,23923,1],[23,23,1]])
t = np.random.randint(0,10000,size=s.shape)
t[1] = s[0] + 1

s1 = Scanner("""404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401
""")
t1 = Scanner("""686,422,578
605,423,415
515,917,-361
-336,658,858
-476,619,847
-460,603,-452
729,430,532
-322,571,750
-355,545,-477
413,935,-424
-391,539,-444
553,889,-390""")

arr = s1.find_translations(t1)
assert arr is not None

def build_map(scanners, m=12, beacons: np.array = None):
    if beacons is None:
        beacons = scanners[0].arr.copy()
    for s in scanners:
        for t in scanners:
            if s is not t:
                f = s.find_translations(t, m)
                if f is not None:
                    beacons = beacons.concatentate([beacons,f])
                    scanners.pop(scanners.index(t))
                    beacons = build_map(scanners, m, beacons)
    return beacons

s = """--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401

--- scanner 1 ---
686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390

--- scanner 2 ---
649,640,665
682,-795,504
-784,533,-524
-644,584,-595
-588,-843,648
-30,6,44
-674,560,763
500,723,-460
609,671,-379
-555,-800,653
-675,-892,-343
697,-426,-610
578,704,681
493,664,-388
-671,-858,530
-667,343,800
571,-461,-707
-138,-166,112
-889,563,-600
646,-828,498
640,759,510
-630,509,768
-681,-892,-333
673,-379,-804
-742,-814,-386
577,-820,562

--- scanner 3 ---
-589,542,597
605,-692,669
-500,565,-823
-660,373,557
-458,-679,-417
-488,449,543
-626,468,-788
338,-750,-386
528,-832,-391
562,-778,733
-938,-730,414
543,643,-506
-524,371,-870
407,773,750
-104,29,83
378,-903,-323
-778,-728,485
426,699,580
-438,-605,-362
-469,-447,-387
509,732,623
647,635,-688
-868,-804,481
614,-800,639
595,780,-596

--- scanner 4 ---
727,592,562
-293,-554,779
441,611,-461
-714,465,-776
-743,427,-804
-660,-479,-426
832,-632,460
927,-485,-438
408,393,-506
466,436,-512
110,16,151
-258,-428,682
-393,719,612
-211,-452,876
808,-476,-593
-575,615,604
-485,667,467
-680,325,-822
-627,-443,-432
872,-547,-609
833,512,582
807,604,487
839,-516,451
891,-625,532
-652,-548,-490
30,-46,-14"""
test = build_map(parse_string(s))

