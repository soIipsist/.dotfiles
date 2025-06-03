from ast import literal_eval
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


def map_sqlite_results_to_objects(
    sqlite_results: list, object_type, column_names: list = []
):
    """Maps SQLite query results to a list of objects"""
    objects = []
    if len(column_names) > 0:
        for result in sqlite_results:
            o = object_type(*result)

            for name, result in zip(column_names, result):
                # check if result is array
                if (
                    isinstance(result, str)
                    and result.startswith("[")
                    and result.endswith("]")
                ):
                    result = literal_eval(result)
                if (
                    isinstance(result, str)
                    and result.startswith("{")
                    and result.endswith("}")
                ):
                    result = literal_eval(result)

                setattr(o, name, result)
            objects.append(o)
    else:
        objects = [object_type(*row) for row in sqlite_results]
    return objects
