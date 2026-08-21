-- extract and join
SELECT
    f.sales_id,
    f.invoice_date,
    f.client_key,
    c.client_segment,
    c.county,
    f.product_key,
    p.product_name,
    p.category,
    p.unit_cost,
    p.unit_price,
    f.quantity_ordered,
    f.invoiced_unit_price
FROM fact_sales f
INNER JOIN dim_clients c ON f.client_key = c.client_key
INNER JOIN dim_products p ON f.product_key = p.product_key;