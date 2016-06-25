"""Make list of indicators for web app and print to stdout. Paste these into
/heroku/forms.py , instead of loading from database each time

"""


import psycopg2
import pandas as pd

def make_df(query):
    query = query
    cursor.execute(query)

    columns = [desc[0] for desc in cursor.description]
    return pd.DataFrame(cursor.fetchall(), columns=columns)


conn = psycopg2.connect("dbname='indicators'")
cursor = conn.cursor()

# this not strictly necessary if all indicators are in `metadata`
query = """SELECT distinct indicator from indicators;"""
indicator_df = make_df(query)

query = """SELECT indicator, label_short from metadata;"""
label_df = make_df(query)

df = indicator_df.merge(label_df)

print [tuple(x) for x in df.to_records(index=False)]
