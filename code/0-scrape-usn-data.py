# scrape USN's top 60 countries
import requests
import re
import warnings
import pandas as pd                # for export
import pickle                      # for export
from bs4 import BeautifulSoup   # html parser
from collections import namedtuple # like a dict
from urlparse import urljoin 


def dl_data(url):
    print "Downloading data..."
    r = requests.get(url)
    print "Done."
    return r


def get_country_info(item):
    name = item.text
    url = item['href']
    return CountryStore(name=name, url=url)


def get_countries(raw):
    soup = BeautifulSoup(raw.text, "html.parser")
    divs = soup.find_all('div', attrs={'class': 'small-12 column'})
    p = divs[1].select('p')[0]
    return [get_country_info(c) for c in p.select('a') if get_country_info(c) is not None]


def get_subrank_info(item):
    name = item.text
    url = item['href'].replace(BASEURL, "")
    return name, url


def tofloat(text):
    t = text.strip().replace("(", "")
    try:
        float(t)
        return float(t)
    except ValueError:
        warnings.warn("Warning: Did not get a float where needed.")
        return False

    
def get_attributes(raw):
    soup = BeautifulSoup(raw.text, "html.parser")
    div = soup.select('span#docs-internal-guid-c27701e2-0e7e-7a4a-d5bd-469d49804385')
    # name, url:
    alinks = div[0].find_all('a')
    # weights:
    wts = re.findall('<b>(\S?\d+\.\d+ )percent\S?<\/b>', str(div))
    # lists of attributes:
    aa = div[0].find_all('span')
    la = []
    for i in range(len(aa)):
        if i % 3 ==0:
            t = aa[i].text.replace(u"\xa0", "").replace("<span>", "")
            t = t.replace("): ", "")
            la.append(t.split(", "))
    # COMBINE:
    res = []
    for i in range(len(wts)):
        wts[i] = tofloat(wts[i])
        name, url = get_subrank_info(alinks[i])
        # last one manually (:
        if i == len(wts)-1:
            la.append("a good job market, affordable, economically stable, family friendly, income equality, politically stable, safe, well-developed public education system, well-developed public health system".split(", "))
        res.append(AttributeStore(subranking=name, url=url, weight=wts[i], attributes=la[i]))
    return res


BASEURL = "http://www.usnews.com"

post1 = "/news/best-countries/data-explorer"
r1 = dl_data(urljoin(BASEURL, post1))
post2= "/news/best-countries/articles/methodology"
r2 = dl_data(urljoin(BASEURL, post2))

CountryStore = namedtuple("CountryStore", 'name, url')
countries = get_countries(r1)
print "Found %i countries." % len(countries) # 60

AttributeStore = namedtuple("AttributeStore", 'subranking, url, weight, attributes')
attributes = get_attributes(r2)
print "Found %i subrankings." % len(attributes)  # 9

dfc = pd.DataFrame.from_records(countries, columns=CountryStore._fields)
print dfc.head()

# TODO: fix list from attributes. they are a list of one list
dfa = pd.DataFrame.from_records(attributes, columns=AttributeStore._fields)
print dfa

outfile = open("../cache/countries.pickle", "wb")
pickle.dump(dfc, outfile)
outfile.close()

outfile = open("../cache/attributes.pickle", "wb")
pickle.dump(dfa, outfile)
outfile.close()
