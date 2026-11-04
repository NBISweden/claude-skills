import gzip
import sys


def mean_quality(path):
    """Mean Phred quality over all reads in a FASTQ file."""
    total = n = 0
    opener = gzip.open if path.endswith(".gz") else open
    with opener(path, "rt") as fh:
        for i, line in enumerate(fh):
            if i % 4 == 3:
                total += sum(ord(c) - 33 for c in line.strip())
                n += len(line.strip())
    return total / n if n else 0.0


if __name__ == "__main__":
    print(mean_quality(sys.argv[1]))
