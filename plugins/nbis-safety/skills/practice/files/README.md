# NBIS agent practice project

Everything here is made up: the code, the test and the reads. Nothing in
it belongs to anyone, so a mistake here costs nothing.

- `src/qc.py`: computes the mean Phred quality of a FASTQ file. It has a
  bug.
- `tests/test_qc.py`: a test that fails because of that bug. Run it from
  this folder with `python3 tests/test_qc.py`.
- `tests/fixture.fastq`: four made-up reads the test uses.
- `data/sample1.fastq`: made-up reads standing in for a researcher's data.
  In a real project this is the folder the agent must not read.

Delete the folder when you are done.
