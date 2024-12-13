---
aliases:
  - Database Transformation and Analysis Project
tags: []
siblings: 
linter-alias: Database Transformation and Analysis Project
---
# Database Transformation and Analysis Project

This project transforms a raw dataset (`RAW_MOCK_DATA`) into a structured relational database and conducts detailed analyses to derive actionable insights. The process includes identifying and correcting data issues, creating normalized tables, and performing SQL queries to answer key business questions.

---

## Table of Contents
- [Project Overview](#project-overview)
- [Database Schema](#database-schema)
- [Data Cleaning and Transformation](#data-cleaning-and-transformation)
- [Key Insights and Analyses](#key-insights-and-analyses)
- [Future Steps](#future-steps)

---

## Project Overview

The raw dataset contains customer, product, and order information with the following data issues:

- **Misused `product_name` field**: Contains customer salutations.
- **Static date strings**: Dates are not in a usable format.
- **Erroneous `postcode` field**: Includes commas and inconsistent formatting.

The goal is to build a normalized database with four main tables (`customers`, `products`, `orders`, `order_details`) and perform meaningful analyses, including revenue breakdowns and customer segmentation.

---

## Database Schema
### **1. Customers**
- **Columns**: `customer_id`, `salutation`, `first_name`, `last_name`, `email`, `age`, `gender`, `city`, `state`, `zipcode`
- Includes cleaned and formatted customer data.
### **2. Products**
- **Columns**: `product_id`, `product_name`, `category`, `price`
- Stores unique product data.
### **3. Orders**
- **Columns**: `order_id`, `customer_id`, `purchase_date`, `total_amount`
- Contains high-level order details, including total purchase amounts.
### **4. Order Details**
- **Columns**: `order_id`, `product_id`, `quantity`, `price_per_unit`
- Connects orders to individual products.

---

## Data Cleaning and Transformation
### Key Steps:
1. **Extract and Clean Customer Data**:
   - Corrected `postcode` format (removed commas, ensured 5-character consistency).
   - Verified email validity using regex.
2. **Normalize Product Data**:
   - Removed duplicates and aligned `product_name` to correct values.
3. **Split and Normalize Order Data**:
   - Created `orders` and `order_details` tables to separate metadata and details.
   - Converted static date strings into proper `DATE` format.
4. **Add Constraints and Relationships**:
   - Established primary and foreign key relationships between tables for referential integrity.

---

## Key Insights and Analyses

### **1. Top Revenue-Generating Product (2021)**
- **Query**: Analyzed products contributing the highest percentage of revenue.
- **Result**: The **Smart Home Speaker** generated the greatest percentage of revenue.
### **2. Revenue Trends by Category**
- **Query**: Compared revenue changes quarter-over-quarter for the latest two quarters (Q3 vs. Q4 2021).
- **Result**:
  - **Home Goods**: Revenue increased.
  - **Kitchen and Electronics**: Revenue decreased.
### **3. High-Value Customer Segments**
- **Query**: Identified customer segments (by state, gender, and average age) contributing to the top 20% of cumulative revenue.
- **Result**:
  - **Male Californians** contributed the most to revenue, followed closely by **Female Californians**.
  - Notable observation: Customers aged 75+ form the top revenue segment, indicating an older customer base.
#### **Age Range Distribution**
- **Query**: Analyzed revenue and customer distribution by age range.
- **Result**:
  - The top customer age segment, both in percentage of customers and revenue, is **75+**.
### **4. Month-to-Month Revenue Variations by Product Category**
- **Query**: Analyzed monthly sales trends and identified seasonal peaks and troughs for each product category.
- **Results**:
  - **Electronics**: Revenue peaked in **April** and **August**, with significant dips surrounding these months.
  - **Home Goods**: Revenue trends remained relatively stable, with a slight peak in **February**.
  - **Kitchen**: Revenue exhibited erratic behavior, with strong early-year performance that softened as the year progressed.

#### **Month-to-Month Percentage Change**
- **Query**: Measured percentage change in revenue month-over-month across categories.
- **Results**:
  - Electronics experienced the most dramatic shifts, particularly a **large drop in May** and a sharp **peak in August**.
  - Home Goods displayed minimal variations, confirming its stable performance.
  - Kitchen showed steep declines after a strong start, reflecting its volatile nature.

---

## Future Steps
1. **Create a Dashboard for Ongoing Analyses**:
   - Build an interactive dashboard to track metrics like month-over-month revenue changes.
3. **Document the Insights in an Ad Hoc Report**:
   - Include visualizations to communicate findings effectively.

---

## How to Use This Project
1. Clone this repository
2. Load the `RAW_MOCK_DATA` dataset into your SQL environment.
3. Execute the SQL scripts in sequential order to:
    - Clean and transform data.
    - Create the normalized database schema.
    - Run queries to generate insights.

---

## License

This project is licensed under the MIT License. See `LICENSE` for details.

---

## Acknowledgments

Special thanks to the SQL and data engineering community for their guidance and tools that made this project possible.