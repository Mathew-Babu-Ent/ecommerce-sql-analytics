# GitHub Publishing Preparation

This is a local preparation checklist. Publishing is not performed by these steps.

- [x] Execute and validate all three analysis scripts against the intended `ecommerce` database.
- [x] Save the resulting `results/*.tsv` files and confirm they contain no credentials or real personal data.
- [x] Replace the pending marker in `docs/business_insights.md` with findings supported by the saved outputs.
- [x] Update the README project status after Phase 3–5 work is complete.
- [ ] Review `git status` and inspect the staged diff before committing.
- [ ] Create a GitHub repository, add it as `origin`, and push only after reviewing the repository contents.

The seed uses synthetic names, reserved `example.com` email addresses, and non-routable sample phone labels. Never add local credentials, MySQL option files, database dumps from a real system, or unrelated personal files.
