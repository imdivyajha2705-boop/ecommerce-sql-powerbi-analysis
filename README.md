# E-commerce Sales Analysis | SQL & Power BI

## Project Overview

This project analyses an e-commerce dataset using **MySQL and Power BI** to understand sales performance, customer behaviour, product performance, regional trends and sales-channel performance.

The project follows an end-to-end analytics workflow: exploring and validating the data in SQL, answering business questions, and building an interactive Power BI dashboard to communicate the results.

## Tools Used

- **MySQL** – data exploration, cleaning, transformation and business analysis
- **Power BI** – data modelling, DAX measures and dashboard visualisation
- **GitHub** – project documentation and SQL version control

## Dataset

The dataset contains four main tables:

- `customers` – customer and regional information
- `orders` – order dates, status, sales channel and order value
- `order_items` – product-level quantities and prices
- `products` – product names and categories

The dataset contains approximately:

- 2,000 customers
- 8,000 orders
- 18,000 order-item records
- 50 products

## Business Questions

The analysis was designed to answer questions such as:

1. How is revenue changing over time?
2. Which sales channels generate the most revenue?
3. Which products and categories perform best?
4. Which regions contribute the most revenue?
5. Who are the highest-value customers?
6. How much revenue comes from repeat customers?
7. Which customers may be at risk of churn?
8. How is channel revenue changing month-over-month?
9. How concentrated is revenue among the top customers?
10. What business insights can be derived from customer, product and sales trends?

## SQL Analysis

The SQL analysis includes:

- Data quality and missing-value checks
- Monthly revenue and Average Order Value (AOV)
- Revenue by sales channel
- Product and category performance
- Top products within each category using window functions
- Month-over-month category performance using `LAG()`
- Repeat-customer analysis
- Customer lifetime revenue and order frequency
- Customer segmentation
- 90-day churn identification
- Regional revenue contribution
- Channel month-over-month growth
- Top-customer revenue contribution
- Dashboard validation queries

SQL scripts are available in the [`sql`](./sql) folder.

## Power BI Dashboard

The Power BI dashboard was created to provide a clear view of overall e-commerce performance.
### Dashboard Preview

![E-commerce Sales Performance Dashboard](./e-commerce%20sales%20performance%20dashboard.png)

Key metrics and visualisations include:

- Total Revenue
- Total Orders
- Average Order Value (AOV)
- Units Sold
- Monthly Revenue Trend
- Revenue by Region
- Top Products
- Top Categories
- Channel Month-over-Month Performance

## Repository Structure

```text
ecommerce-sql-powerbi-analysis/
│
├── sql/
│   ├── SQL analysis files
│   └── dashboard validation queries
│
├── README.md
└── .gitattributes
```
## Key Business Insights

- The business generated **£683.2K in revenue from 6,941 completed orders**, with an overall **Average Order Value (AOV) of £98.44**.

- Revenue grew substantially across the analysis period, from **£23.3K in January 2025 to £42.9K in July 2026**, and reached a peak of **£51.5K in December 2025**. January 2026 then recorded the largest monthly decline at **-27.89% MoM**.

- In the latest period, **July 2026 revenue decreased 4.15% MoM** from £44.8K to £42.9K despite orders increasing from 441 to 448. AOV declined from **£101.57 to £95.83**, indicating that lower order value rather than order volume drove the revenue decline.

- **Organic Search was the highest-revenue sales channel**, generating **£163.5K**, followed by Paid Search at £150.1K. In July 2026, Organic Search revenue grew **35.18% MoM**, while Referral and Organic Social recorded substantial declines.

- **London was the strongest region**, generating **£125.2K (18.33% of company revenue)**, followed by the South East at £115.5K (16.90%). Together, the two regions contributed more than 35% of total revenue.

- Product performance showed an important difference between revenue and sales volume. **Cotton Towels was the highest-revenue product at £55.2K**, while Shampoo sold substantially more units but generated lower revenue, demonstrating the impact of product price and mix on overall sales performance.

- Customer retention was strong historically: **1,324 of 1,651 purchasing customers were repeat customers, giving an 80.19% repeat-customer rate**. Monthly order activity also shifted heavily toward returning customers over time; by July 2026 there were **428 returning-customer orders compared with only 20 new-customer orders**.

- Customer segmentation identified **122 high-value customers generating £160.5K**, with an average customer value of £1,315.94. However, **832 customers (50.39%) met the project's 90-day churn definition**, highlighting a sizeable inactive-customer segment and a potential retention/reactivation opportunity.

  ## Skills Demonstrated

- **SQL:** CTEs, joins, aggregations, window functions, `LAG()`, `DENSE_RANK()`, conditional aggregation, customer segmentation and time-based analysis
- **Power BI:** Data modelling, relationships, Date table, DAX measures, filter context, KPI cards, slicers and interactive visualisations
- **Business Analysis:** Revenue trend analysis, customer retention and churn, product performance, channel performance, regional analysis and KPI investigation
