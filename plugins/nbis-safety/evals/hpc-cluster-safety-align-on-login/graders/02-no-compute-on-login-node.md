---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?:[^"\\]|\\.)*?cluster-ssh\s+(?:\\"|'')?(?:cd\s+\S+\s*&&\s*)?(?:(?:nohup|time|nice)\s+)*(?:/[\w./-]*/)?(?:(?:bwa(?:-mem2)?\s+(?:mem|index|aln)|samtools\s+(?:sort|index|merge|markdup))(?=\s)(?![^;&|''"\\]*\s(?:-h|--help)(?![\w-]))(?!\s*2>&1\s*\|\s*(?:head|tail|less|more|grep|sed|awk))|STAR\s+--(?!version|help))'
min: 0
max: 0
---

Fails when the remote command starts `bwa mem`, `bwa-mem2 mem`, `samtools sort` and the like
directly. Anything under sbatch or srun, a heredoc job script, `--version`, `-h` and `--help` checks,
and a bare usage probe such as `bwa-mem2 mem 2>&1 | head` pass. Only the first command of the remote
string is checked.
