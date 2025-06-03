import sqlite3


def execute_query(conn: sqlite3.Connection, query: str, params: list = None):
    cursor = None
    results = []

    try:
        cursor = conn.cursor()
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        results = cursor.fetchall()
        conn.commit()

    except sqlite3.Error as e:
        print("Error executing query:", e)

    return results


def get_sqlite_connection(database_path: sqlite3.Connection):
    db = None

    try:
        db = sqlite3.connect(database_path)
    except sqlite3.Error as e:
        print("Error connecting to the database:", e)
        print("Database path: ", database_path)

    return db


def create_objects_from_sqlite_results(results: list):
    pass
