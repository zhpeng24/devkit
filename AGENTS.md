# Devkit

## Development constitution

- Test quality matters more than test count, coverage theater, or repeated runs.
- Each test must target a real failure mode, contain a meaningful assertion,
  and fail when the protected behavior is broken.
- During implementation, run only focused checks that inform the next change.
- Finish a coherent feature or repair batch before running its regression
  suite; run the broader project regression once before delivery.
- Do not rerun an unchanged suite when relevant code, configuration,
  dependencies, fixtures, and environment have not changed.
- Move tests earlier only for risk that justifies it, such as bug reproduction,
  security, data migration, concurrency, public API compatibility, or
  cross-platform behavior.
- Batch documentation, skill, and metadata edits before static validation.
  Do not start a full regression or independent review for every edited file.
