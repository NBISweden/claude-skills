## What and why

<!-- One or two sentences. Link the issue if there is one. -->

## Checklist

- [ ] I am in `CODEOWNERS` for what I added or own
- [ ] Version bumped in the plugin's `plugin.json` (patch for fixes, minor for new items)
- [ ] At least one eval case covers the change, and I ran it locally:
      `claude plugin eval plugins/<plugin> --scaffold --trust-plugin`
- [ ] Every new script has a test in the plugin's `tests/`
- [ ] New skills or hooks have a row in the README table
- [ ] No real data, personal data, keys or internal hostnames in fixtures, evals or examples

## For the reviewer

<!-- What to look at first, and anything you are unsure about. -->
