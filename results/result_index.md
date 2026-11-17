# Analysis Result Index

The three TSV snapshots are the actual result sets produced by running the corresponding SQL analysis scripts against the `ecommerce` MySQL database. Result sets appear in SQL statement order; this index maps each set to its question. The row count is the number of data rows, excluding the TSV header. Q28 is a single grouped result row (`Match` with 1,500 orders).

| Question | Result file | Rows | Result shape |
|---|---|---:|---|
| Q01 | `04_beginner_analysis.tsv` | 10 | Oldest pending-order dates |
| Q02 | `04_beginner_analysis.tsv` | 8 | Distinct categories |
| Q03 | `04_beginner_analysis.tsv` | 10 | Highest current catalog prices |
| Q04 | `04_beginner_analysis.tsv` | 12 | Products with stock at/below 25 |
| Q05 | `04_beginner_analysis.tsv` | 10 | Recent Mumbai signups |
| Q06 | `04_beginner_analysis.tsv` | 85 | January 2026 orders |
| Q07 | `04_beginner_analysis.tsv` | 6 | Distinct payment methods |
| Q08 | `04_beginner_analysis.tsv` | 15 | Recent failed attempts |
| Q09 | `04_beginner_analysis.tsv` | 10 | Newest catalog additions |
| Q10 | `05_intermediate_analysis.tsv` | 8 | Category orders, units, and delivered sales |
| Q11 | `05_intermediate_analysis.tsv` | 19 | Monthly delivered orders and sales |
| Q12 | `05_intermediate_analysis.tsv` | 8 | Categories over the unit threshold |
| Q13 | `05_intermediate_analysis.tsv` | 5 | Top customers by delivered item sales |
| Q14 | `05_intermediate_analysis.tsv` | 375 | Customers with at least two delivered orders |
| Q15 | `05_intermediate_analysis.tsv` | 35 | Seller performance |
| Q16 | `05_intermediate_analysis.tsv` | 12 | City delivered-sales totals |
| Q17 | `05_intermediate_analysis.tsv` | 6 | Mean successful payment amount by method |
| Q18 | `05_intermediate_analysis.tsv` | 6 | Attempt outcomes by method |
| Q19 | `05_intermediate_analysis.tsv` | 4 | Order-value statistics by order status |
| Q20 | `06_advanced_analysis.tsv` | 19 | Monthly sales with running total |
| Q21 | `06_advanced_analysis.tsv` | 24 | Top three ranked products per category |
| Q22 | `06_advanced_analysis.tsv` | 35 | Seller `DENSE_RANK` leaderboard |
| Q23 | `06_advanced_analysis.tsv` | 500 | Most recent order per customer |
| Q24 | `06_advanced_analysis.tsv` | 256 | Customers above average delivered sales |
| Q25 | `06_advanced_analysis.tsv` | 19 | Monthly sales and prior-month delta |
| Q26 | `06_advanced_analysis.tsv` | 19 | Monthly view output |
| Q27 | `06_advanced_analysis.tsv` | 5 | Stored procedure: top five Electronics products |
| Q28 | `06_advanced_analysis.tsv` | 1 | Per-order item/payment amount check |
| Q29 | `06_advanced_analysis.tsv` | 12 | City `RANK` leaderboard |

## Review checks

- Q11 and Q26 agree on monthly delivered order counts, units, and item sales.
- Q10 category sales sum to Q20's ending running total of 24,873,109.44.
- Q15 and Q22 agree on seller-sales ranking; Q16 and Q29 agree on city-sales ranking.
- Q28 reports `Match` for all 1,500 orders and no mismatch group.
- The payment method result sets show 250 attempts per method, with 200 successful, 25 pending, and 25 failed for each method.

See [business_insights.md](../docs/business_insights.md) for interpreted findings, metric definitions, and caveats.
