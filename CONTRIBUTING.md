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

## Pull Requests

- Keep PRs focused and small when possible.
- Include a short description of changes and how you verified them.
- If outputs change, describe the reason and data provenance.

## Contact

For questions, open an issue in this repository.
