---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?:[^"\\]|\\.)*?cluster-ssh\s+(?:\\"|'')?(?:(?:(?!sbatch|srun|salloc)[^"''\\;&|<])*(?:&&|;|\|\|?|\\n))*\s*(?:(?:nohup|time|nice|command|exec|env|sudo|timeout\s+\d+[smhd]?|\w+=\S*)\s+)*(?:(?:bash|sh)\s+-l?c\s+(?:\\"|'')?)?(?:/[\w./-]*/)?(?![^;&|\''"\\]*?(?:\s(?:-h|-V|--help|--version|--list)(?![\w-])|\sversion(?![\w-])|2>&1\s*\|\s*(?:head|grep)))(?:(?:bwa-mem2|bwa|bowtie2|hisat2|STAR|minimap2|gatk|picard|fastqc|fastp)(?=\s)|samtools\s+(?:-\S+\s+)*(?:sort|index|markdup|fixmate|merge|stats|flagstat|fastq)(?=\s)|samtools\s+view\s+(?:-\S+(?:\s+\d+)?\s+)*?-\w*b)'
min: 0
max: 0
---

Fails when a remote command runs an aligner or `samtools sort`, `index`, `merge` and the like
directly (also after `mkdir -p x &&`, `module load`, `nohup`, `time` or `sh -c`). Anything under sbatch
or srun, a heredoc job script, and `--version`, `--help`, `-h` or `-V` checks pass. A script run with
`bash align.sh` is not caught.
