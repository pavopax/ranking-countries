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
query = """SELECT distinct indicator from indicators;"""
indicator_df = make_df(query)

query = """SELECT indicator, label_short from metadata;"""
label_df = make_df(query)

# final subsets 
all_df = indicator_df.merge(label_df)

# subsets of indicators
basic = "AG.LND.TOTL.K2 SP.POP.TOTL NY.GDP.PCAP.PP.CD SP.POP.GROW".split()
optimism = "econ_optimism happiness hope".split()
fancy = "IC.TAX.GIFT.ZS LP.LPI.TIME.XQ IC.WRH.PROC IC.TAX.PAYM IC.ISV.DURS IC.REG.DURS IQ.SCI.OVRL".split()
combined = basic + optimism + extra

print "All indicators:"
print tuple_it(df)

print "Basic:"
print tuple_it(df[df.indicator.isin(basic)])

print "Optimism:"
print tuple_it(df[df.indicator.isin(optimism)])

print "Fancy:"
print tuple_it(df[df.indicator.isin(fancy)])

print "Anti-combined:"
print tuple_it(df[-df.indicator.isin(combined)])
