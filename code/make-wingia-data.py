import pandas as pd

data = []


with open("../data/wingia-economic-optimism-table-2-1.txt", 'r') as f:
    for row in f:
        x = row.rstrip('\n').split()
        # LAST 5 positions are the 5 value columns, the rest is the country name
        if len(x)==6:
            data.append(x)
        else:
            values = x[-5:]
            country = ' '.join(x[:len(x)-5])
            data.append([country]+values)

# print [len(x) for x in data]


for row in data:
    row = [x.rstrip('%') for x in row]
