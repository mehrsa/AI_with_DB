import psycopg2
from get_conn import get_connection_uri
from dotenv import load_dotenv
load_dotenv(override=True)


def execute_sql_file(cursor, sql_file_path):
    with open(sql_file_path, 'r', encoding="utf-8") as file:
        sql = file.read()
        print(f"Executing SQL file: {sql_file_path}")
        print(sql)  # Debug print to verify the content of the SQL file
        try:
            cursor.execute(sql)
        except Exception as e:
            print(f"Error executing SQL file: {e}")
        


if __name__ == "__main__":

    try:

        conn_string = get_connection_uri()
        connection = psycopg2.connect(conn_string)

        # Create a cursor object
        cursor = connection.cursor()
        # Execute a query to verify the setup
        cursor.execute("SELECT version();")
        db_version = cursor.fetchone()
        print(f"Successfully Connected to - {db_version}")
    except Exception as error:
        print(f"Error connecting to the database: {error}")


    # Replace with path to the SQL file
    file_path = "ABC_co.sql"
    try:
        # Execute the SQL file
        execute_sql_file(cursor, file_path)
        # Commit the changes
        connection.commit()
        # Close the cursor and connection
        cursor.close()
        connection.close()
        print(f"Successfully set up the tables and closed the connection.")
    except Exception as e:
        print(f"Error setting up the tables: {e}")
        # Rollback the changes
        connection.rollback()
        # Close the cursor and connection
        cursor.close()
        connection.close()
        print("Rolled back the changes and closed the connection.")
