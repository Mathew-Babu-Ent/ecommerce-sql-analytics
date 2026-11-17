# Business Question Index

Each query file contains the complete question, SQL concepts, query, logic explanation, and business use in SQL comments immediately before the query.

## Beginner — `sql/04_beginner_analysis.sql` (9 questions)

| ID | Business question | Main concepts |
|---|---|---|
| Q01 | Which pending orders have the oldest order dates? | `WHERE`, `ORDER BY`, `LIMIT` |
| Q02 | Which product categories are in the catalog? | `DISTINCT` |
| Q03 | Which products have the highest current list prices? | `ORDER BY`, `LIMIT` |
| Q04 | Which products are running low on stock? | Filtering and sorting |
| Q05 | Which Mumbai customers signed up most recently? | `WHERE`, dates, `LIMIT` |
| Q06 | Which orders were placed in January 2026? | Date ranges |
| Q07 | What payment methods appear in payment records? | `DISTINCT` |
| Q08 | Which orders have failed payment attempts? | `WHERE`, sorting |
| Q09 | Which products were added to the catalog most recently? | Dates, sorting |

## Intermediate — `sql/05_intermediate_analysis.sql` (10 questions)

| ID | Business question | Main concepts |
|---|---|---|
| Q10 | Units and delivered item sales by category? | `INNER JOIN`, `COUNT`, `SUM`, `GROUP BY` |
| Q11 | Delivered item sales by calendar month? | `DATE_FORMAT`, aggregation |
| Q12 | Which categories generated at least 100 delivered units? | `HAVING` |
| Q13 | Which five customers generated the most delivered item sales? | Joins, aggregation, top-N |
| Q14 | Which customers placed at least two delivered orders? | `COUNT`, `HAVING` |
| Q15 | Seller comparison by delivered sales and order reach? | Multi-table joins, aggregation |
| Q16 | Which customer cities contribute the most delivered sales? | Joins, geography |
| Q17 | Average successful payment amount by method? | `AVG`, `CASE` |
| Q18 | Payment attempts by method and outcome? | `COUNT`, conditional aggregation |
| Q19 | Average, minimum, and maximum order value by status? | Subquery, `AVG`, `MIN`, `MAX` |

## Advanced — `sql/06_advanced_analysis.sql` (10 questions)

| ID | Business question | Main concepts |
|---|---|---|
| Q20 | Monthly delivered sales and cumulative running total? | CTE, windowed `SUM` |
| Q21 | Top products by delivered sales within each category? | `RANK`, partitioning |
| Q22 | Seller leaders with tie-aware ranking? | `DENSE_RANK` |
| Q23 | Most recent order for each customer? | `ROW_NUMBER` |
| Q24 | Customers above average delivered item sales? | CTE, subquery, `LEFT JOIN` |
| Q25 | Month-over-month delivered sales change? | `LAG`, CTE, dates |
| Q26 | Reusable monthly delivered sales summary? | View |
| Q27 | Top products in a selected category? | Stored procedure |
| Q28 | Do payment amounts match order item totals? | CTE, `CASE`, grain control |
| Q29 | How do cities rank by delivered item sales? | CTE, `RANK` |

The final set has 29 questions total (9 beginner, 10 intermediate, 10 advanced).
