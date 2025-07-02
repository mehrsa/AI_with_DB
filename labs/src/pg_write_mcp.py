# Copyright (c) Microsoft. All rights reserved.
import argparse
import logging
from typing import Annotated, Any, Literal
import psycopg2
import json
import anyio

from semantic_kernel.agents import ChatCompletionAgent
from semantic_kernel.connectors.ai.open_ai import AzureChatCompletion
from semantic_kernel.functions import kernel_function

logger = logging.getLogger(__name__)


from get_conn import get_connection_uri
from psycopg2 import pool

def parse_arguments():
    parser = argparse.ArgumentParser(description="Run the Semantic Kernel MCP server.")
    parser.add_argument(
        "--transport",
        type=str,
        choices=["sse", "stdio"],
        default="stdio",
        help="Transport method to use (default: stdio).",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=None,
        help="Port to use for SSE transport (required if transport is 'sse').",
    )
    return parser.parse_args()

connection_pool = None
def init_pool():
    # Initialize connection pool
    global connection_pool
    if connection_pool is None:
        conn_string = get_connection_uri()
        connection_pool = pool.SimpleConnectionPool(
            minconn=1,
            maxconn=10,
            dsn=conn_string
        )


class Contoso_WritePlugin:
    def __init__(self):
        init_pool()
    @kernel_function
    async def get_procedure_info(self) -> str:
        global connection_pool
        """Gets information about available stored procedures in the database."""
        conn = connection_pool.getconn()
        res = ""
        try:
            procedure_query = """
            SELECT
                routine_schema,
                routine_name,
                routine_type,
                data_type AS return_type,
                specific_name
            FROM information_schema.routines
            WHERE routine_schema = 'public'
            ORDER BY routine_schema, routine_name;
            """
            curs = conn.cursor()
            curs.execute(procedure_query)
            columns = [desc[0] for desc in curs.description]
            rows = curs.fetchall()
            curs.close()
            proc_info = [dict(zip(columns, row)) for row in rows]
            res =  json.dumps(proc_info, indent=2)
        except Exception as e:
            print(f"Could not execute query: {e}")
            res =  ""
        finally:
            connection_pool.putconn(conn)
        return res

    @kernel_function
    async def execute_write_query(self, query: str) -> list:
        global connection_pool
        res = []
        if not query.startswith("SELECT"):
            conn = connection_pool.getconn()
            try:
                query_cursor = conn.cursor()
                query_cursor.execute(query)
                res = ["Operation successful"]
                conn.commit()     
            except psycopg2.Error as e:
                conn.rollback()
                res = ["Could not perform the operation due to error: " + str(e)]   
            finally:
                query_cursor.close()
                connection_pool.putconn(conn)
            return res
    @kernel_function
    async def get_db_schema(self) -> str:
        global connection_pool
        """Gets the database schema."""
        res = ""
        conn = connection_pool.getconn()
        try:
            
            query = """
            SELECT
                cols.table_schema,
                cols.table_name,
                cols.column_name,
                cols.data_type,
                cols.is_nullable,
                cons.constraint_type,
                cons.constraint_name,
                fk.references_table AS referenced_table,
                fk.references_column AS referenced_column
            FROM information_schema.columns cols
            LEFT JOIN information_schema.key_column_usage kcu
                ON cols.table_schema = kcu.table_schema
                AND cols.table_name = kcu.table_name
                AND cols.column_name = kcu.column_name
            LEFT JOIN information_schema.table_constraints cons
                ON kcu.table_schema = cons.table_schema
                AND kcu.table_name = cons.table_name
                AND kcu.constraint_name = cons.constraint_name
            LEFT JOIN (
                SELECT
                    rc.constraint_name,
                    kcu.table_name AS references_table,
                    kcu.column_name AS references_column
                FROM information_schema.referential_constraints rc
                JOIN information_schema.key_column_usage kcu
                    ON rc.unique_constraint_name = kcu.constraint_name
            ) fk
                ON cons.constraint_name = fk.constraint_name
            WHERE cols.table_schema = 'public'
            ORDER BY cols.table_schema, cols.table_name, cols.ordinal_position;
            """
            curs = conn.cursor()
            curs.execute(query)
            columns = [desc[0] for desc in curs.description]
            rows = curs.fetchall()
            curs.close()
            schema_info = [dict(zip(columns, row)) for row in rows]
            res = json.dumps(schema_info, indent=2)
        except Exception as e:
            print(f"Could not fetch database schema: {e}")
            res = ""
        finally:
            connection_pool.putconn(conn)
        return res



async def run(transport: Literal["stdio"] = "stdio", port: int | None = None) -> None:
    agent = ChatCompletionAgent(
        service=AzureChatCompletion(),
        name="WriteAgent",
        instructions="""You are responsible for modifying data in the database while maintaining referential integrity.

                        Below are the instructions you must follow:
                        - You must always first esnure you have the database schema.
                        - For adding a new record, ensure that there is value provided for all required NOT NULL columns. Ask the user for any missing values.
                        - Always prioritize using a stored procedure if available for that operation.
                        - You can also create new stored procedures.
                        - Stored procedures should not have OUT parameters.
                        - In case of a duplicate record, add the new record with a different primary key value. 
                        - You must always ensure that the operation does not violate referential integrity.
                        - Before running the query, you must always first show the query to user and ask user for confirmation.
                        """,
        plugins=[Contoso_WritePlugin()],  # add the plugin to the agent
    )

    server = agent.as_mcp_server()

    if transport == "stdio":
        from mcp.server.stdio import stdio_server

        async def handle_stdin(stdin: Any | None = None, stdout: Any | None = None) -> None:
            async with stdio_server() as (read_stream, write_stream):
                await server.run(read_stream, write_stream, server.create_initialization_options())

        await handle_stdin()


if __name__ == "__main__":
    args = parse_arguments()
    anyio.run(run, args.transport, args.port)