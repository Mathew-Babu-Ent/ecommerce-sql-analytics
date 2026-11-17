# Phase 2 Completion Record

## Environment findings

- MySQL Community Server 8.0.46 and its command-line client are installed under the standard Windows Program Files location.
- The client is not on PATH.
- The user confirmed `MySQL80` is running and verified `SELECT VERSION()` with the local client.
- This workspace's local client defaults to `ODBC` without a password and receives MySQL error 1045. The project owner executed the schema, seed, and verification scripts locally using an authenticated session.
- No installation is needed. For local script runs, use the installed client with the correct username; `--password` prompts securely. Do not paste the password into chat or commit it to Git.
- No separate portfolio guide document was present in the project folder. The business question list will therefore be built from the requirements in the project brief.

## Decisions

1. `order_items.unit_price` records the price when purchased; later product price changes do not rewrite history.
2. The requested status and payment scenarios use explicit allowed-value CHECK constraints.
3. Seed data will be generated with a SQL stored procedure and a documented numeric seed. The generator will use deterministic arithmetic and fixed vocabularies instead of unseeded `RAND()`, so the same seed yields the same records.
4. Generation will insert parents before children and run in a transaction with foreign-key checks enabled.
5. Business findings will be written only after the database is loaded and SQL queries have been run.

## Phase 2 validation issue follow-up

- The original 3x payment-total result was caused by validation query grain, not by payment generation: the query joined one payment per order to the order's three item rows and then summed the repeated payment amount. The seed procedure accumulates each of the three `quantity * unit_price` line amounts into one order total and inserts that amount once for the order.
- `sql/03_verify_data.sql` now aggregates item values to one row per order before comparing them to each payment. It reports all payment/order amount mismatches and separately compares successful payments against delivered/returned order value.
- The generator now makes every cancelled order's payment attempt `Failed`, so no cancellation represents an unrefunded successful charge. Returned orders retain their original successful payment; refund processing is documented as outside the sample model.
- The generator now enforces the full requested mapping: Pending → Pending, Cancelled → Failed, Delivered/Returned → Successful. The verification SQL reports any order/payment status mismatch.
- The project owner reported that final Phase 2 verification passed and approved the phase: expected counts in all six tables; zero orphan records; zero payment/order amount mismatches; matching settled item sales and payment totals; zero payment status mismatches; and zero cancelled orders with successful payments.

## Project status after Phase 3 result capture

- Schema, seed data, and integrity verification: completed and approved by the project owner.
- The three analysis scripts were run against the actual database; outputs are saved under `results/` and indexed in `results/result_index.md`.
- Findings and README have been completed from those result files; GitHub publishing remains deferred at the user's request.
