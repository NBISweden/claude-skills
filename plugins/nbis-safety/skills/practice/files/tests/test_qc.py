import sys, pathlib; sys.path.insert(0, str(pathlib.Path(__file__).parent.parent / "src"))
from qc import mean_quality

# Four made-up reads: three at Phred 40, one at Phred 0, so the mean is 30.0.
assert mean_quality(str(pathlib.Path(__file__).parent / "fixture.fastq")) == 30.0
print("test_qc: ok")
