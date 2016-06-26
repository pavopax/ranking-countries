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


def tuple_it(df):
    return [tuple(x) for x in df.to_records(index=False)]


conn = psycopg2.connect("dbname='indicators'")
cursor = conn.cursor()

# this not strictly necessary if all indicators are in `metadata`
query = """SELECT distinct indicator, subset from indicators;"""
all_indicator_df = make_df(query).sort_values(['subset', 'indicator'])


query = """SELECT indicator, label_short from metadata;"""
label_df = make_df(query)

# final subsets 
df = all_indicator_df.merge(label_df)

# subsets of indicators
optimism = "econ_optimism happiness hope".split()
optimism_df = df[df.indicator.isin(optimism)].drop('subset', axis=1)

fancy_df = df[df.subset==2].drop('subset', axis=1)
indicator_df = df[df.subset==1].drop('subset', axis=1)


print "optimism"
print tuple_it(optimism_df)

print "fancy"
print tuple_it(fancy_df)

print "main"
print tuple_it(indicator_df)
