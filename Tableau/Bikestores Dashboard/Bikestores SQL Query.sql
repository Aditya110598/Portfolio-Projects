SELECT
      o.order_id,
	  CONCAT(c.first_name,' ',c.last_name) AS Customers,
	  c.city,
	  c.state,
	  o.order_date,
	  SUM(i.quantity) AS Total_units,
	  SUM(i.quantity * i.list_price) AS Revenue,
	  p.product_name,
	  ca.category_name,
	  s.store_name,
	  CONCAT(st.first_name,' ',st.last_name) AS Sales_representative
FROM sales.orders AS o
JOIN sales.customers AS c
ON o.customer_id = c.customer_id
JOIN sales.order_items AS i
ON o.order_id = i.order_id
JOIN production.products AS p
ON i.product_id = P.product_id
JOIN production.categories AS ca
ON p.category_id = ca.category_id
JOIN sales.stores AS s
ON o.store_id = s.store_id
JOIN sales.staffs AS st
ON o.staff_id = st.staff_id
GROUP BY 
         o.order_id,
	  CONCAT(c.first_name,' ',c.last_name),
	  c.city,
	  c.state,
	  o.order_date,
	  p.product_name,
	  ca.category_name,
	  s.store_name,
	  CONCAT(st.first_name,' ',st.last_name)