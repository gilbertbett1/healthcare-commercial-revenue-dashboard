import os
from pathlib import Path
from urllib.parse import quote_plus

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()
db_user = os.getenv("DB_USER")
db_password = quote_plus(os.getenv("DB_PASSWORD"))
db_host = os.getenv("DB_HOST")
db_port = os.getenv("DB_PORT")
db_name = os.getenv("DB_NAME")  # Use the database name from .env

engine = create_engine(f"mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}")

DATA_DIR = Path(r"C:\data-analytics\health_data_analytics\healthcare-commercial-revenue-dashboard\data")
products = pd.read_csv(DATA_DIR / "sales_products.csv")
clients = pd.read_csv(DATA_DIR / "sales_clients.csv")
sales = pd.read_csv(DATA_DIR / "sales_raw.csv")

products.to_sql("dim_products", engine, if_exists="append", index=False)
clients.to_sql("dim_clients", engine, if_exists="append", index=False)
sales.to_sql("fact_sales", engine, if_exists="append", index=False)

with engine.connect() as conn:
    for table, src_df in [("dim_products", products), ("dim_clients", clients), ("fact_sales", sales)]:
        db_count = conn.execute(text(f"SELECT COUNT(*) FROM {table}")).scalar()
        print(f"{table}: CSV={len(src_df)} DB={db_count} [{'OK' if db_count==len(src_df) else 'MISMATCH'}]")
    orphan_c = conn.execute(text("SELECT COUNT(*) FROM fact_sales f LEFT JOIN dim_clients c ON f.client_key=c.client_key WHERE c.client_key IS NULL")).scalar()
    orphan_p = conn.execute(text("SELECT COUNT(*) FROM fact_sales f LEFT JOIN dim_products p ON f.product_key=p.product_key WHERE p.product_key IS NULL")).scalar()
    print(f"Orphaned client refs: {orphan_c}  Orphaned product refs: {orphan_p}")
print("Load complete.")