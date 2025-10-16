
This SQL script is divided into structured sections for a full end-to-end EDA workflow:
1. Database Setup**
2. Data Preview & Exploration**
3. Missing Values & Duplicate Checks**
4. Data Cleaning & Validation**
5. Descriptive Statistics**
6. Sales & Revenue Insights**
7. Time-Based Trends**
8. Customer & Product Analysis**
9. Return and Refund Analysis**
10. Geographical Insights**
11. Data Integrity Verification**



 🧠 Key Analyses

- Total revenue by product category and region  
- Top 5 revenue-generating products  
- Average Order Value (AOV) and monthly revenue trends  
- Customer retention and cohort analysis  
- Return rate and refund impact  
- Data consistency & outlier detection  



 🧹 Data Cleaning Steps

- Removed duplicate records using `ROW_NUMBER()` and `DELETE`  
- Replaced missing or invalid email and region fields  
- Checked for NULLs across all key tables  
- Validated relationships between customers, orders, and products  



 🛠️ Technologies Used
- MySQL
- SQL Window Functions
- Aggregate & Join Operations
- CTEs and Analytical Queries



 🚀 How to Use
1. Create a new database (e.g., `ecommercedb`).
2. Import your tables (`customers`, `orders`, `order_items`, `products`, `returns`).
3. Run each SQL section step-by-step.
4. Review results and insights from query outputs.


 📊 Example Insights
| Metric | Example Query |
|---------|----------------|
| **Top Categories by Revenue** | `SELECT category, SUM(quantity*item_price)` |
| **Monthly Revenue Trend** | `DATE_FORMAT(order_date, '%Y-%m')` |
| **Average Order Value** | `SELECT AVG(total_amount)` |
| **Return Rate** | `COUNT(DISTINCT r.order_id)/COUNT(DISTINCT o.order_id)` |
| **Regional Revenue** | `GROUP BY region` |

---

 📈 Business Insights Uncovered
- Electronics and Apparel are top-selling categories  
- Most revenue is generated in Q4 months  
- A small segment of loyal customers contributes major revenue share  
- Return rate averages around X% (can be calculated after running queries)



 👨‍💻 Author
CHAITANYA BHENDARKAR 
📧 [chaitanyabhendarkar0@gmail.com]  
💼 [https://www.linkedin.com/in/chaitanya-bhendarkar-159a92389/]

