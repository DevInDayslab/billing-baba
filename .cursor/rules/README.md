# Cursor

## Purpose

This directory contains project-specific Cursor configuration for **Billing Baba**.

Billing Baba will use a **single project-specific Cursor Rule** generated after project setup is complete. The rule will capture the project's architecture, coding conventions, and development guidelines so Cursor generates code that follows existing patterns.

Flutter-specific and backend-specific rules are not part of this template — they will be consolidated into the single project rule once the codebase structure is finalized.

## Workflow

1. Complete project setup (repository structure, tech stack, documentation).
2. Finalize architecture and folder structure.
3. Generate a project-specific Cursor Rule using Cursor's built-in rule generation.
4. Review and refine the generated rule before development begins.
5. Update the rule whenever major architectural or workflow changes occur.

## Guidelines

- Keep the rule concise and focused.
- Include only project-specific conventions.
- Avoid duplicating documentation from the `docs/` directory.
- Update the rule as the project evolves.
- Remove outdated instructions.

## Best Practices

- One project, one primary Cursor Rule.
- Prefer modifying the existing rule instead of creating multiple overlapping rules.
- Treat the Cursor Rule as part of the project's architecture.
- Review the rule periodically to ensure it reflects the current codebase.

## Notes

The project-specific Cursor Rule is generated after project setup and is not part of this template.
