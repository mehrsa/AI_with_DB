import psycopg2
from pandas import DataFrame
from typing import Optional
from semantic_kernel.functions import kernel_function


class ABC_DataPlugin:
    def __init__(self, db_uri: str):
        self.conn = psycopg2.connect(db_uri)
        self.cursor = self.conn.cursor()
        print("Connected to company's database successfully.")

    @kernel_function
    async def get_product_info(self, product_name: Optional[str] = None, product_id: Optional[int] = None) -> list[dict]:
        """Gets all product information from the database."""
        query = """SELECT 
                    product_id,                   
                    name,
                    inventory,
                    price,
                    refurbished,
                    category
                FROM products
                WHERE (LOWER(name) = LOWER(%(product_name)s) AND %(product_name)s IS NOT NULL)
                   OR (product_id = %(product_id)s AND %(product_id)s IS NOT NULL)
                   """
        if not product_name and not product_id:
            print("No valid product name or ID provided.")
            return None
        elif product_id:
            self.cursor.execute(query, {"product_name": None, "product_id": product_id})
        else:
            self.cursor.execute(query, {"product_name": product_name, "product_id": None})

            
        rows = self.cursor.fetchall()
        columns = [desc[0] for desc in self.cursor.description]
        try:
            products= DataFrame(rows, columns=columns)
            products.to_dict(orient="records")  # <-- JSON serializabl
            
            return products.to_dict(orient="records")  # <-- JSON serializabl
        except Exception as e:
            print(f"Error fetching product information: {e}")
            return None
    @kernel_function
    def most_sold_product(self, category: str) -> Optional[dict]:
        """Returns the most sold product in a given category."""
        query = """
            SELECT products.product_id, products.name, SUM(sales.quantity) AS total_sold
            FROM sales
            JOIN products ON sales.product_id = products.product_id
            WHERE LOWER(products.category) = LOWER(%(category)s) 
            GROUP BY products.product_id, products.name
            ORDER BY total_sold DESC
            LIMIT 1;
        """
        self.cursor.execute(query, {"category": category})
        row = self.cursor.fetchone()
        if row:
            columns = [desc[0] for desc in self.cursor.description]
            return dict(zip(columns, row))
        else:
            print(f"No sales data found for category: {category}")
            return None
    @kernel_function
    async def add_product(self, name: str, description: str, price: float,
                           inventory: int, refurbished: bool, category: str ) -> bool:
        """Adds a new product to the database."""
        query = """INSERT INTO products (name, description, price, inventory, refurbished, category)
                   VALUES (%(name)s, %(description)s, %(price)s, %(inventory)s, %(refurbished)s, %(category)s);"""  
        try:
            self.cursor.execute(
                query,
                {
                    "name": name,
                    "description": description,
                    "price": price,
                    "inventory": inventory,
                    "refurbished": refurbished,
                    "category": category
                }
            )
            self.conn.commit()
            print(f"Product '{name}' added successfully.")
            return True
        except Exception as e:
            print(f"Error adding product: {e}")
            self.conn.rollback()
            return False

    def close_connection(self):
        """Closes the database connection."""
        self.cursor.close()
        self.conn.close()
        print("Database connection closed.")
    

