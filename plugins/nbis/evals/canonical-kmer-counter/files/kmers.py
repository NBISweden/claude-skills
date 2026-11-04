"""Canonical k-mer counting for genome size estimation (2-bit rolling hash)."""

ENC = {"A": 0, "C": 1, "G": 2, "T": 3}


def decode(code, k):
    """Turn a 2-bit encoded k-mer back into a string."""
    return "".join("ACGT"[(code >> (2 * (k - 1 - i))) & 3] for i in range(k))


def count_kmers(seq, k):
    """Count canonical k-mers in seq, skipping any k-mer that contains a non-ACGT base."""
    mask = (1 << (2 * k)) - 1
    shift = 2 * (k - 1)
    fwd = rev = 0
    filled = 0
    counts = {}
    for base in seq.upper():
        if base not in ENC:
            continue
        b = ENC[base]
        fwd = ((fwd << 2) | b) & mask
        rev = (rev >> 2) | ((3 - b) << shift)
        filled += 1
        if filled >= k:
            kmer = decode(min(fwd, rev), k)
            counts[kmer] = counts.get(kmer, 0) + 1
    return counts
