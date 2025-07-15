import pyodbc
import json
import os
from dotenv import load_dotenv

load_dotenv()

# Database connection configuration
server = os.getenv('SQL_SERVER')
database = os.getenv('SQL_DB_NAME')
username = os.getenv('SQL_UID')
password = input("Enter your SQL password: ")

connection_string = f"""
DRIVER={{ODBC Driver 18 for SQL Server}};
SERVER={server};
DATABASE={database};
UID={username};
PWD={password};
Encrypt=yes;
TrustServerCertificate=no;
"""

class JSONToSQLInserter:
    def __init__(self):
        """Initialize database connection"""
        try:
            self.conn = pyodbc.connect(connection_string)
            print("Database connection established successfully")
        except Exception as e:
            print(f"Database connection failed: {e}")
            self.conn = None

    def close_connection(self):
        """Close database connection"""
        if self.conn:
            self.conn.commit()
            self.conn.close()
            print("Database connection closed successfully")

    def create_table_if_not_exists(self):
        """Create product_catalogue table if it doesn't exist"""
        if not self.conn:
            return False
            
        try:
            cursor = self.conn.cursor()
            
            # Check if table exists
            check_table_sql = """
            IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
                         WHERE TABLE_NAME = 'products_catalogue')
            BEGIN
                CREATE TABLE dbo.products_catalogue (
                    id INTEGER PRIMARY KEY,
                    prod_id INTEGER,
                    name NVARCHAR(MAX),
                    category NVARCHAR(255),
                    description NVARCHAR(MAX),
                    description_dup NVARCHAR(MAX),
                    price REAL
                );
                PRINT 'Table products_catalogue created successfully';
            END
            ELSE
            BEGIN
                PRINT 'Table products_catalogue already exists';
            END
            """
            
            cursor.execute(check_table_sql)
            self.conn.commit()
            print("Table verification/creation completed")
            return True
            
        except Exception as e:
            print(f"Error creating table: {e}")
            return False

    def load_json_data(self, json_file_path):
        """Load and validate JSON data from file"""
        try:
            # Try different possible paths
            possible_paths = [
                json_file_path,
                os.path.join('src', json_file_path),
                os.path.join('labs', 'src', json_file_path),
                os.path.join('..', json_file_path),
                os.path.join('..', '..', json_file_path)
            ]
            
            json_data = None
            used_path = None
            
            for path in possible_paths:
                try:
                    with open(path, 'r', encoding='utf-8') as file:
                        json_data = json.load(file)
                        used_path = path
                        break
                except FileNotFoundError:
                    continue
            
            if json_data is None:
                print(f"Could not find {json_file_path} in any expected locations")
                return []
            
            return json_data
            
        except json.JSONDecodeError as e:
            print(f"Invalid JSON format: {e}")
            return []
        except Exception as e:
            print(f"Error loading JSON file: {e}")
            return []

    def get_data(self, json_data):
        """Validate and clean JSON data before insertion"""
        valid_products = []
        invalid_count = 0
        for i, product in enumerate(json_data):
            try:

                # Clean and validate data types
                product = {
                    'id': int(product['id']),
                    'prod_id': int(product['id']),
                    'name': str(product['name']).strip(),
                    'category': str(product['category']).strip(),
                    'description': str(product['description']).strip(),
                    'description_dup': str(product['description']).strip(),
                    'price': float(product['price'])
                }
                
                valid_products.append(product)
                
            except (ValueError, KeyError, TypeError) as e:
                print(f"Record {i+1} validation error: {e}")
                invalid_count += 1
                continue
        
        print(f"Valid records: {len(valid_products)}")
        print(f"Invalid records: {invalid_count}")
        
        return valid_products

    def insert_products(self, products, batch_size=100):
        """Insert products into the database"""
        if not self.conn or not products:
            print("No connection or no products to insert")
            return False
        
        try:
            cursor = self.conn.cursor()
            
            
            # Prepare INSERT statement
            insert_sql = """
            INSERT INTO dbo.products_catalogue (id, prod_id, name, category, description, description_dup, price)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """
            
            # Insert in batches for better performance
            total_inserted = 0
            batch_count = 0
            
            for i in range(0, len(products), batch_size):
                batch = products[i:i + batch_size]
                batch_data = [
                    (p['id'], p['prod_id'], p['name'], p['category'], p['description'], p['description_dup'], p['price'])
                    for p in batch
                ]
                
                try:
                    cursor.executemany(insert_sql, batch_data)
                    self.conn.commit()
                    total_inserted += len(batch)
                    batch_count += 1
                    print(f"Batch {batch_count}: Inserted {len(batch)} products")
                    
                except pyodbc.IntegrityError as e:
                    if "PRIMARY KEY constraint" in str(e):
                        print(f"Batch {batch_count}: Some products already exist, trying individual inserts...")
                        # Try inserting one by one to handle duplicates
                        for product_data in batch_data:
                            try:
                                cursor.execute(insert_sql, product_data)
                                self.conn.commit()
                                total_inserted += 1
                            except pyodbc.IntegrityError:
                                print(f"Skipping duplicate product ID: {product_data[0]}")
                                continue
                    else:
                        raise e
            
            print(f"Successfully inserted {total_inserted} products!")
            return True
            
        except Exception as e:
            print(f"Error inserting products: {e}")
            return False


def main():
    # Initialize inserter
    inserter = JSONToSQLInserter()
    
    if not inserter.conn:
        print("Cannot proceed without database connection")
        return
    
    try:
        # Create table if needed
        if not inserter.create_table_if_not_exists():
            print("Failed to create/verify table")
            return
        
        # Load JSON data
        json_file = 'sample_products.json'
        json_data = inserter.load_json_data(json_file)
        
        if not json_data:
            print("No data loaded from JSON file")
            return
        
        # Validate and clean data
        valid_products = inserter.get_data(json_data)
        
        if not valid_products:
            print("No valid products found after validation")
            return

        
        # Insert products
        _ = inserter.insert_products(
            valid_products, 
            batch_size=100
        )
        

    except KeyboardInterrupt:
        print("Process interrupted by user")
    except Exception as e:
        print(f" Unexpected error: {e}")
    finally:
        inserter.close_connection()

if __name__ == '__main__':
    main()