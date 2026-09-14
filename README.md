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
