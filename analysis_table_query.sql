CREATE OR REPLACE TABLE `rakaminkfanalytics-459816.kf_dataset.analysis_table` AS
SELECT 
  ft.transaction_id,
  ft.date,
  ft.branch_id,
  c.branch_name,
  c.kota,
  c.provinsi,
  c.rating AS rating_cabang,
  ft.customer_name,
  ft.product_id,
  p.product_name,
  p.price AS actual_price,
  ft.discount_percentage,

  -- Nett Sales = harga setelah diskon
  (p.price - (p.price * ft.discount_percentage / 100)) AS nett_sales,

  -- Laba Persen (gross margin berdasarkan price bracket)
  CASE
    WHEN p.price BETWEEN 0 AND 50000 THEN 0.10
    WHEN p.price BETWEEN 50001 AND 100000 THEN 0.15
    WHEN p.price BETWEEN 100001 AND 300000 THEN 0.20
    WHEN p.price BETWEEN 300001 AND 500000 THEN 0.25
    ELSE 0.30
  END AS laba_persen,

  -- Nett Profit = nett_sales * laba_persen
  ((p.price - (p.price * ft.discount_percentage / 100)) *
   CASE
     WHEN p.price BETWEEN 0 AND 50000 THEN 0.10
     WHEN p.price BETWEEN 50001 AND 100000 THEN 0.15
     WHEN p.price BETWEEN 100001 AND 300000 THEN 0.20
     WHEN p.price BETWEEN 300001 AND 500000 THEN 0.25
     ELSE 0.30
   END) AS nett_profit,

  ft.rating AS rating_transaksi

FROM `rakaminkfanalytics-459816.kf_dataset.final_transaction` ft
JOIN `rakaminkfanalytics-459816.kf_dataset.product` p
  ON ft.product_id = p.product_id
JOIN `rakaminkfanalytics-459816.kf_dataset.cabang` c
  ON ft.branch_id = c.branch_id;
