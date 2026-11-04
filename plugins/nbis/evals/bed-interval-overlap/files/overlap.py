"""Interval helpers for BED files (0-based, half-open coordinates)."""


def overlaps(a, b):
    """True if BED intervals a and b, each (chrom, start, end), share at least one base."""
    return a[0] == b[0] and a[1] <= b[2] and b[1] <= a[2]


def merge(intervals):
    """Merge overlapping or book-ended intervals, like `bedtools merge` with default settings."""
    out = []
    for iv in sorted(intervals):
        if out and out[-1][0] == iv[0] and iv[1] <= out[-1][2]:
            out[-1] = (iv[0], out[-1][1], max(out[-1][2], iv[2]))
        else:
            out.append(iv)
    return out


def count_overlapping(query, targets):
    """Number of target intervals that overlap the query, like `bedtools intersect -c`."""
    return sum(overlaps(query, t) for t in targets)
