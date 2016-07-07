"""Find similar countries, given one country, using affinity clustering.
Input: pandas DF.  Output: list of countries.

Explore this with "../code/python-explore/affinity-propagation.ipynb"

"""

import numpy as np
import pandas as pd
from sklearn.cluster import AffinityPropagation


def get_similar_countries(df, given_country):
    """Return list of similar countries to given_country, from df, using
    AffinityPropagation

    """

    af = AffinityPropagation().fit(np.array(df))
    
    # TODO ? find better way than converting to pd
    label_map = pd.DataFrame({"label": af.labels_,
                              "country": df.index})
    # want to return countries that have same clustering label as the given country
    similarity_label = label_map[label_map.country.isin([given_country])].label
    similar_countries = (label_map[label_map.label.isin(similarity_label)]
                         .country.tolist()
                         )
    # list includes original_country, so exclude it
    if len(similar_countries)==1:
        return ["None"]
    else:
        return [c for c in similar_countries if c != given_country]
    
    
