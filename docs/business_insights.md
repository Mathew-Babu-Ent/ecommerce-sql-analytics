# Business Insights

## Evidence and scope

These findings come from the actual MySQL query outputs saved as `results/04_beginner_analysis.tsv`, `results/05_intermediate_analysis.tsv`, and `results/06_advanced_analysis.tsv`. The outputs are indexed by question in [result_index.md](../results/result_index.md). Phase 2 row counts and integrity checks were separately confirmed by the project owner.

The SQL files were reviewed against their output sets. The analysis outputs are consistent with their query logic. Query Q01's wording was clarified: the schema records `order_date`, not a status-transition timestamp, so it can identify the oldest pending order dates but cannot measure exact time spent pending. The query itself and its result are unchanged.

## Metric definitions

- **Delivered item sales (primary merchandise sales measure):** `SUM(order_items.quantity * order_items.unit_price)` for orders whose status is `Delivered`. This excludes pending, cancelled, and returned orders.
- **Order value:** sum of purchase-time line values for one order. Queries that join payment information aggregate item rows to one row per order first.
- **Successful payment amount:** `payments.payment_amount` on rows whose status is `Successful`. This amount is the original charge/collection amount. Returned orders retain a successful original payment, and refund transactions are not modeled; therefore successful payment amount is gross before refunds, not net revenue.
- **Attempted/expected payment amount:** the seed stores the order total in the payment row even when the attempt is pending or failed. Such rows are not settled revenue.
- **Average order value in Q19:** average of per-order item totals within each order status. Only the Delivered row should be interpreted as delivered basket AOV. Cancelled and pending rows are attempted basket values; Returned reflects the original item value before any unmodeled refund.
- **Currency:** amounts are reported in the database's numeric currency units. There is no currency-code column, so this project does not assert a formal ISO currency.

The 3-item-per-order design means raw item rows must never be joined directly to one payment row and then summed. The earlier Phase 2 verification query exposed that fan-out and was corrected. Q28 now reports one row per order after aggregating item values first; its result is `Match = 1,500` and no `Mismatch` rows.

## Executive summary

- Q10 and Q20 show **24,873,109.44 delivered item-sales units** across **1,125 delivered orders**. The last running-total row in Q20 and the category sales in Q10 reconcile to the same delivered item-sales amount.
- Q19 reports a delivered order AOV of **22,109.43**.
- Electronics leads delivered sales at **13,430,272.02**, about **54.0%** of all delivered item sales. Electronics, Home & Kitchen, and Sports together contribute about **76.8%**.
- Grocery and Books lead unit volume (1,652 and 1,648 units respectively) despite ranking fifth and sixth by sales value. This points to different basket-price profiles, not necessarily different profitability; margin data is absent.
- The leading delivered product is **Wireless Headphones Model 049** (product 49): **1,885,231.26** in sales from **117 units**.
- Kochi is the highest-sales customer city at **2,771,152.60**; Pune is a close second at **2,763,059.82**.
- Every payment method has the same recorded attempt mix: 250 attempts, 200 successful, 25 pending, and 25 failed. Debit Card has the highest average successful payment amount (**25,970.79**); the count mix is tied across methods.
- The data is intentionally synthetic and its customer/order assignment creates unusually uniform behavior. These results demonstrate SQL methods; they should not be treated as market forecasts.

## Sales by product category

Source: Q10 (category delivered sales and units), Q12 (delivered unit filter).

| Category | Delivered orders represented | Delivered units | Delivered item sales | Share of delivered item sales |
|---|---:|---:|---:|---:|
| Electronics | 448 | 1,344 | 13,430,272.02 | 54.0% |
| Home & Kitchen | 415 | 830 | 3,278,031.16 | 13.2% |
| Sports | 410 | 820 | 2,398,609.12 | 9.6% |
| Beauty | 452 | 1,356 | 2,109,273.66 | 8.5% |
| Grocery | 413 | 1,652 | 1,107,648.88 | 4.5% |
| Books | 412 | 1,648 | 974,462.88 | 3.9% |
| Toys | 414 | 414 | 866,730.50 | 3.5% |
| Clothing | 411 | 411 | 708,081.22 | 2.8% |

The category order count is distinct orders containing at least one item in that category. Since an order can include items from several categories, category order counts are not additive to the 1,125 total delivered orders.

**Observation:** Electronics is the dominant sales-value category. Grocery and Books move the most units but generate far less sales value per unit on average. Home & Kitchen and Sports are the next largest sales-value categories.

**Recommendations:** Protect availability and seller coverage for leading Electronics items. Test complementary bundles or cross-sell placements for high-volume Grocery and Books. Before making assortment or promotion decisions, add margin, discount, and stock-history data; sales value alone does not show profit or lost demand.

## Leading products

Sources: Q21 (top three within each category, ranked by delivered item sales) and Q27 (top five in Electronics).

| Category | Top product | Units | Delivered item sales |
|---|---|---:|---:|
| Beauty | Hydrating Face Serum Model 029 (ID 29) | 114 | 241,724.70 |
| Books | Contemporary Fiction Model 020 (ID 20) | 156 | 124,325.44 |
| Clothing | Everyday Cotton Shirt Model 003 (ID 3) | 24 | 83,588.40 |
| Electronics | Wireless Headphones Model 049 (ID 49) | 117 | 1,885,231.26 |
| Grocery | Organic Tea Selection Model 040 (ID 40) | 156 | 141,155.76 |
| Home & Kitchen | Ceramic Cookware Set Model 042 (ID 42) | 76 | 558,351.36 |
| Sports | Trail Running Bottle Model 102 (ID 102) | 74 | 358,101.60 |
| Toys | Wooden Building Blocks Model 071 (ID 71) | 37 | 123,346.86 |

Q27's top five Electronics products are IDs 49, 33, 65, 9, and 57. Model 049 leads that list at 1,885,231.26. Q21 ranks within categories; the Electronics leader also exceeds the other category leaders in this result set.

**Recommendations:** Use product-level demand to inform replenishment planning, but compare sales with current stock, margin, return rate, and stockout history before prioritizing inventory. Those supporting measures are not fully available in this dataset.

## Customer behavior

Sources: Q13 (top five customers), Q14 (repeat delivered orders), Q23 (most recent order per customer), Q24 (customers above average delivered sales).

| Customer ID | Name in sample | Delivered orders | Delivered item sales |
|---:|---|---:|---:|
| 389 | Aarav Bose | 3 | 124,664.54 |
| 469 | Aarav Bose | 3 | 124,664.54 |
| 349 | Aarav Bose | 3 | 124,449.58 |
| 429 | Aarav Bose | 3 | 124,449.58 |
| 137 | Neel Iyer | 3 | 119,837.26 |

Customer IDs are shown because generated names repeat and are not unique identifiers. Q14 returns **375 customers**, each with **three delivered orders**. Q24 identifies **256 customers** whose delivered item-sales total exceeds the average across all 500 registered customers.

**Data-pattern caveat:** The seed assigns exactly three orders to each customer, and the deterministic status cycle makes those three orders share the same status. The result is 375 customers with three delivered orders and 125 customers whose three orders are all pending, cancelled, or returned (as reflected in latest-order statuses in Q23). This makes the 75% repeat-delivery figure a generator artifact, not a credible real-world retention rate. It is useful for demonstrating grouping and ranking SQL only.

**Recommendations:** In a production analysis, segment customers using varied purchase frequency and recency, include customer acquisition cohorts, and calculate retention over time. Do not target a real loyalty program using this synthetic 75% figure.

## Seller performance

Sources: Q15 and Q22. Ranking is by delivered item sales; use seller ID because generated seller names can repeat.

| Rank | Seller ID | Seller name | Delivered orders | Units | Delivered item sales |
|---:|---:|---|---:|---:|---:|
| 1 | 31 | Blue Peak Commerce | 113 | 289 | 2,097,378.70 |
| 2 | 4 | Cobalt Works Commerce | 88 | 241 | 1,797,068.70 |
| 3 | 16 | Cobalt Works Commerce | 112 | 282 | 1,687,862.18 |
| 4 | 23 | Urban Loom Commerce | 88 | 274 | 1,546,522.70 |
| 5 | 27 | Willow Market Commerce | 86 | 248 | 1,367,225.20 |

**Recommendations:** Review the leading sellers' catalog coverage and fulfillment quality, then compare sales concentration with margins and cancellation/return rates. Sales alone is not a complete seller-quality measure.

## City performance

Source: Q16 and Q29; city is the customer's recorded city. Amounts include Delivered orders only.

| Rank | City | Delivered orders | Delivered item sales |
|---:|---|---:|---:|
| 1 | Kochi | 102 | 2,771,152.60 |
| 2 | Pune | 99 | 2,763,059.82 |
| 3 | Delhi | 99 | 2,630,588.18 |
| 4 | Bengaluru | 99 | 2,600,107.34 |
| 5 | Kolkata | 99 | 2,535,256.34 |
| 6 | Lucknow | 102 | 2,413,803.00 |
| 7 | Indore | 99 | 2,303,722.42 |
| 8 | Ahmedabad | 102 | 2,213,149.44 |
| 9 | Hyderabad | 99 | 2,085,433.74 |
| 10 | Jaipur | 78 | 876,889.68 |
| 11 | Chennai | 75 | 863,760.80 |
| 12 | Mumbai | 72 | 816,186.08 |

**Recommendations:** Kochi and Pune are the strongest sample cities by delivered sales; investigate local category mix and order value before shifting marketing spend. The synthetic city/customer allocation is not representative enough to justify real geographic budget decisions.

## Order values and lifecycle

Source: Q19. Values below are per-order item totals, not payment totals.

| Order status | Orders | Average item order value | Minimum | Maximum |
|---|---:|---:|---:|---:|
| Delivered | 1,125 | 22,109.43 | 5,354.74 | 63,370.66 |
| Returned | 75 | 10,607.15 | 6,986.48 | 18,588.16 |
| Pending | 150 | 18,111.91 | 5,274.96 | 58,958.22 |
| Cancelled | 150 | 27,046.59 | 9,173.30 | 66,711.26 |

The delivered AOV is 22,109.43. Cancelled and pending basket values are not realized sales. The returned order value describes the original item total; refund amounts are not represented.

## Monthly trend

Sources: Q11 and Q20 (monthly delivered sales and running total), Q25 (month-over-month change), Q26 (view output). The independent monthly query and view agree on month, delivered order count, units, and sales.

| Month | Delivered orders | Delivered item sales |
|---|---:|---:|
| 2025-01 | 62 | 1,401,483.56 |
| 2025-02 | 57 | 1,214,263.30 |
| 2025-03 | 65 | 1,470,824.34 |
| 2025-04 | 63 | 1,416,771.08 |
| 2025-05 | 62 | 1,328,938.34 |
| 2025-06 | 60 | 1,384,990.12 |
| 2025-07 | 64 | 1,335,862.74 |
| 2025-08 | 64 | 1,469,833.42 |
| 2025-09 | 63 | 1,394,692.22 |
| 2025-10 | 66 | 1,413,601.34 |
| 2025-11 | 61 | 1,344,521.54 |
| 2025-12 | 62 | 1,398,736.96 |
| 2026-01 | 64 | 1,355,372.10 |
| 2026-02 | 58 | 1,358,324.10 |
| 2026-03 | 65 | 1,395,107.38 |
| 2026-04 | 62 | 1,404,477.06 |
| 2026-05 | 64 | 1,404,016.94 |
| 2026-06 | 61 | 1,355,117.42 |
| 2026-07* | 2 | 26,175.48 |

Among the 18 complete months from January 2025 through June 2026, March 2025 is highest at 1,470,824.34 and February 2025 is lowest at 1,214,263.30. January 2025 to June 2026 sales changed by about **-3.3%**, so the observed complete-month series is broadly stable rather than showing sustained growth. July 2026 is partial (two delivered orders) and should not be compared as a full month. The complete-month sales values range from about 1.21M to 1.47M.

*July 2026 is partial: the dataset's latest recorded orders are July 1, 2026.

**Recommendations:** Compare full months only, add a longer time series before drawing seasonality conclusions, and annotate partial periods in dashboards. Do not interpret the sharp July decline as a business downturn.

## Payment-method performance

Sources: Q17 (average successful payment amount) and Q18 (attempt counts and outcomes).

| Payment method | Attempts | Successful | Pending | Failed | Average successful payment amount |
|---|---:|---:|---:|---:|---:|
| Debit Card | 250 | 200 | 25 | 25 | 25,970.79 |
| Net Banking | 250 | 200 | 25 | 25 | 23,198.03 |
| Cash on Delivery | 250 | 200 | 25 | 25 | 21,740.95 |
| Credit Card | 250 | 200 | 25 | 25 | 20,880.43 |
| Wallet | 250 | 200 | 25 | 25 | 19,113.32 |
| UPI | 250 | 200 | 25 | 25 | 17,439.71 |

Debit Card has the highest mean successful payment amount. Each method has exactly 200 successful payments, so the average ranking also indicates relative gross payment volume in this sample, subject to the displayed averages being rounded to cents. This does not show that one payment method causes larger orders. Each method also has the same 80% successful, 10% pending, and 10% failed attempt distribution, a strong sign of the generator's balanced pattern rather than real-world payment behavior. Q17 includes returned orders as successful original charges; refunds are not modeled.

**Recommendations:** Treat Debit Card's larger average as a hypothesis only. In real data, compare methods with customer/order mix, fees, authorization rates, and refunds. This sample does not support a payment-method reliability recommendation because its outcomes are perfectly balanced by design.

## Validation and query-output review

- Q28: all 1,500 order/payment amount comparisons returned `Match`; no `Mismatch` group appeared.
- Q10 category sales reconcile to Q20's ending delivered item-sales running total: 24,873,109.44.
- Q11 monthly summary and Q26 view return the same monthly sales, order counts, and unit totals.
- Q21 returns three ranked products per each of eight categories (24 rows); Q27 returns five Electronics products.
- Q22 and Q15 agree on seller sales ordering; Q29 ranks the same city sales as Q16.
- Result set row counts and query mapping are documented in [result_index.md](../results/result_index.md).

## Limitations and interpretation

1. Records are synthetic and generated deterministically. Perfectly balanced payment outcomes, exactly three orders per customer, repeated customer/seller display names, and status patterns are artifacts of the seed design.
2. No profit margin, discounts, tax, shipping charge, inventory movement, or current stock-to-sales history is modeled.
3. Refunds and reversals for returned orders are absent. Successful payment totals are gross before refunds and cannot be called net revenue.
4. There is no currency code. Reported amounts are generic dataset currency units.
5. Order date is available, but status-transition dates are not; elapsed time in a status cannot be measured.
6. Customer city is used as the geographic attribution and may not represent shipping destination.

These findings demonstrate SQL analysis and metric discipline on a controlled sample. They should not be presented as observed market or company performance.
