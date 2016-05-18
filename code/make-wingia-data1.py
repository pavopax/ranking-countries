import pandas as pd

def fix_values(values):
    return [float(x.rstrip('%'))/100. for x in values]

"""take input file, and return good list of rows"""
def make_data(input_file):
    data = []
    for row in input_file:
        try:
            x = row.rstrip('\n').split()
            # LAST 5 positions are the 5 value columns, the rest is the row label
            values = fix_values(x[-5:])
            country = ' '.join(x[:len(x)-5])
            data.append([country]+values)
        except:                 # in happiness, Israel has n/a's
            pass
    return data


with open("../data/wingia-economic-optimism-table-2-1.txt", 'r') as f:
    econ_optimism=make_data(f)

with open("../data/wingia-happiness-table-3-1.txt", 'r') as f:
    happiness=make_data(f)

with open("../data/wingia-hope-table-1-1.txt", 'r') as f:
    hope=make_data(f)

print len(hope), len(happiness), len(econ_optimism)

happiness_cols = ('country happy neutral unhappy dont_know net_happiness'
                  .split())
econ_optimism_cols = ('country optimists pessimists neutrals dont_know net_econ_optimism'
                      .split())
hope_cols = ('country optimists pessimists neutrals dont_know net_hope'
             .split())

df_hope = pd.DataFrame.from_records(hope, columns=hope_cols)
df_happiness = pd.DataFrame.from_records(happiness, columns=happiness_cols)
df_econ_optimism = pd.DataFrame.from_records(econ_optimism, columns=econ_optimism_cols)

# "global average" is in different cases...
df_hope['country'] = df_hope['country'].str.lower()
df_econ_optimism['country'] = df_econ_optimism['country'].str.lower()
df_happiness['country'] = df_happiness['country'].str.lower()

m1 = df_hope[['country', 'net_hope']]
m2 = df_happiness[['country', 'net_happiness']]
m3 = df_econ_optimism[['country', 'net_econ_optimism']]
m12 = pd.merge(m1, m2, how='left', on='country')

wingia = pd.merge(m12, m3, how='left', on='country')
wingia['country'] = wingia['country'].str.title()


wingia.to_csv("../cache/wingia_wide.csv")
df_hope.to_csv("../cache/wingia_hope.csv")
df_happiness.to_csv("../cache/wingia_happiness.csv")
df_econ_optimism.to_csv("../cache/wingia_econ_optimism.csv")
print("DONE")
