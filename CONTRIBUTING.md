# Contributing Guidelines

Thank you for your interest in contributing! This repository produces standardized regional metadata mappings used across UNICEF workflows.

## How to Contribute

- Open an issue describing the improvement or bug.
- For small fixes (typos, docs), feel free to open a PR directly.
- For new regional groupings, include:
  - Source and retrieval date
  - Input files under `raw_data/<GROUPING_NAME>/`
  - Script under `script for output/`
  - Resulting CSV in `output/`

## Development Environment

- R: Use the R project file `Country-and-Region-Metadata.Rproj`. Recommended packages: `data.table`, `dplyr`, `countrycode`.
- Python: See `Python/README.md` for virtual environment and requirements.

## Security & Data Protection

- Do NOT commit microdata (e.g., MICS `.sav`, `.dta`, `.sps`). The `.gitignore` includes patterns to prevent this.
- Do NOT hardcode API keys or tokens. Use environment variables instead. Example: `.env.example`.
- Respect data licensing and attribution for all sources.

## Code Style

- R: Prefer tidyverse style and `data.table` idioms used in this repo.
- Python: Follow PEP 8; run formatters/linters when possible.

## Checks

Run the checks locally before opening or updating a pull request:

```sh
sh tools/qa.sh
```

It confirms the required files are present, scans the full git history for secrets with the [gitleaks](https://github.com/gitleaks/gitleaks/releases) CLI, and compiles every Python script under `Python/`. It needs `gitleaks` on `PATH` (on Windows the portable zip needs no install rights) and Python 3; set `GITLEAKS` or `PYTHON` to point at specific executables. It ends with `QA PASSED` or `QA FAILED` and the commit it checked.

The `Repository QA` workflow runs the same script, but only when started by hand (Actions > Repository QA > Run workflow). It does not run on pushes or pull requests.

## Pull Requests

- Keep PRs focused and small when possible.
- Include a short description of changes and how you verified them, with the last line of `sh tools/qa.sh`.
- If outputs change, describe the reason and data provenance.

## Contact

For questions, open an issue in this repository.
