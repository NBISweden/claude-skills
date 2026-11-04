# claude-skills

Skills for [Claude Code](https://code.claude.com) from NBIS.

| Skill | What it does |
| --- | --- |
| `/nbis:deeper` | Turns a task into a deeper version of itself, not a bigger one: what a top professional would do, the raw material they would start from, their methods and tools, and what would show the result is right. Then rewrites your prompt. Runs only when you call it. |
| `/nbis:verify` | Checks that an algorithm, tool or pipeline does what you claim: property-based and differential tests, workflow and stochastic tests, real data with a known answer, TLA+ for concurrency, Lean 4 for a core algorithm. A bug counts only when a test against the real code fails. |

## Install

In Claude Code:

```
/plugin marketplace add NBISweden/claude-skills
/plugin install nbis@nbisweden
```

Run `/plugin marketplace update nbisweden` to fetch new versions, then
`/reload-plugins` or start a new session to use them.

## Example

```
/nbis:deeper benchmark my read trimmer against fastp
/nbis:verify my k-mer counter in src/kmers.py
```

## Contributing

Each skill is one `SKILL.md` under `skills/<name>/`. Open a pull request.

## License

MIT
