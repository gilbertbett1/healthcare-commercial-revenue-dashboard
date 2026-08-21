-- Create database
CREATE DATABASE IF NOT EXISTS healthcare_sales
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE healthcare_sales;

-- Create tables
CREATE TABLE dim_products (
    product_key     INT PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    category        ENUM('Pharmaceutical', 'Surgical') NOT NULL,
    unit_cost       DECIMAL(10,2) NOT NULL,
    unit_price      DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE dim_clients (
    client_key      INT PRIMARY KEY,
    client_segment  ENUM('Public Hospital', 'Private Hospital', 'Pharmacy') NOT NULL,
    county          VARCHAR(50) NOT NULL,
    INDEX idx_clients_county (county)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE fact_sales (
    sales_id             INT PRIMARY KEY,
    invoice_date         DATE NOT NULL,
    client_key           INT NOT NULL,
    product_key          INT NOT NULL,
    quantity_ordered     INT NOT NULL,
    invoiced_unit_price  DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (client_key) REFERENCES dim_clients(client_key),
    FOREIGN KEY (product_key) REFERENCES dim_products(product_key),
    INDEX idx_sales_date (invoice_date),
    INDEX idx_sales_client (client_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;