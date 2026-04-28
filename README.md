Olist Marketplace Analysis

Logistics, Revenue & Growth Drivers
________________________________________
1. Overview

This project analyzes key drivers of performance in a Brazilian e-commerce marketplace using the Olist dataset.

Focus areas:

•	delivery performance and delays 

•	customer experience (reviews) 

•	logistics and freight pricing 

•	geographic market penetration 

The goal is to identify actionable insights linking operations to business outcomes.
________________________________________
2. Dataset

Source: Kaggle – Brazilian E-commerce Dataset (Olist)

https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

Unit of analysis: 

•	Order-level 

•	Item-level 

Key features:

•	delivery timestamps (purchase, estimated, delivered) 

•	freight value and order value 

•	product category 

•	customer & seller location 

•	review score 
________________________________________
3. Methods & Tools

•	Python (Pandas, NumPy) — data processing 

•	Visualization — Matplotlib / Seaborn 

•	Statistical analysis: 

          o	hypothesis testing (ANOVA, Kruskal-Wallis) 

          o	regression modeling (OLS with interaction terms) 

•	Business analysis: 

          o	market penetration analysis 

          o	revenue & demand structure analysis 
________________________________________
4. Key Insights


Revenue & Sales Structure:

•	Revenue is highly concentrated: TOP-13 categories generate ~70% of total revenue 

•	Seller concentration is high: TOP-5 sellers account for ~67% of category revenue on average 

•	AOV differs significantly by payment type (highest for credit cards, lowest for vouchers) 

•	Most sellers have extremely low sales volume (median ~1 order/month)

•	Customer repeat purchase rate is extremely low: ~97% of users made only one purchase 


Logistics, Geography & Customer Satisfaction:

•	Delivery delays significantly reduce review scores (R² ≈ 0.46) 

•	Impact of delays is non-linear (early delays hurt the most) 

•	Delay impact on rating is stronger when freight is high relative to price 

•	Freight cost is driven more by product weight than distance (R²: 0.37 vs 0.10)

•	Market penetration varies significantly by state, peaking primarily in the Southeastern region

•	Penetration positively correlates with income and negatively with logistics cost (R² ≈ 0.8) 

•	Several states are underpenetrated relative to income and logistics profile → hidden growth potential


Black Friday Insights:

•	Black Friday does not always reduce prices (premiumization effect in some categories) 

•	Customer satisfaction drops during Black Friday (avg −0.45 points) 

•	Rating decline during BF is driven by delivery delays, not order volume 
________________________________________
5. Key Business Recommendations

•	Fix logistics as the core pain point

(reduce delays, improve delivery accuracy, especially in peak periods) 

•	Address the retention gap

(focus on converting one-time buyers into repeat customers) 

•	Reduce seller concentration risk

(support mid-tier sellers, improve distribution) 

•	Expand in underpenetrated high-potential regions
          
(target states with strong income and acceptable logistics)
________________________________________
6. Limitations

•	No direct customer income data (state-level proxy used) 

•	No profit/margin data 

•	Limited time dimension for cohort analysis 
________________________________________
7. Tools Used

•	Python (Pandas, NumPy, SciPy, Statsmodels) 

•	SQL 

•	Jupyter Notebook 

•	Power BI 
________________________________________
8. Project Structure

•	data/

•	├── items_detailed.csv            — prepared item-level data

•	├── orders_detailed.csv           — prepared order-level data

•	└── olist_order_payments_dataset.csv — raw payment data

•	olist_order_analysis.ipynb — order-level analysis 

•	olist_item_analysis.ipynb — item-level analysis 

•	olist_sql_queries.sql — SQL queries 

•	olist_dashboard.pbix — Power BI dashboard 
•	olist_analysis_presentation.pptx — final presentation

