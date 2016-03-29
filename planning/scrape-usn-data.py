# scrapte USN's top 60 countries
import requests
from bs4 import BeautifulSoup   # html parser
from collections import namedtuple # like a dict
from urlparse import urljoin 
import re

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
    soup = BeautifulSoup(raw.text)
    divs = soup.find_all('div', attrs={'class': 'small-12 column'})
    p = divs[1].select('p')[0]      # only one exists
    return [get_country_info(c) for c in p.select('a') if get_country_data(c) is not None]


def get_attr(item):
    name = item.text
    url = item['href']
    return AttributeStore(subranking=name, url=url)

def fixit(text):
    t = text.strip()
    try:
        float(t)
        return float(t)
    except ValueError:
        print "FOUND ERROR. Returning zero"
        raise SystemExit()
        #return 0
        #return False
    
def get_attributes(raw):
    soup = BeautifulSoup(raw.text)
    div = soup.select('span#docs-internal-guid-c27701e2-0e7e-7a4a-d5bd-469d49804385')
    aa = div[0].find_all('a')
    x = re.findall('<b>(\S?\d+\.\d+ )percent\S?<\/b>', str(div))
    x = [fixit(t) for t in x]
    print x
    return [get_attr(attr) for attr in aa if get_attr(attr) is not None]

BASEURL = "http://www.usnews.com"

CountryStore = namedtuple("CountryStore", 'name, url')

post1 = "/news/best-countries/data-explorer"
r1 = dl_data(urljoin(BASEURL, post1))
countries = get_countries(r1)
# print len(country_info) # 60


#AttributeStore = namedtuple("AttributeStore", 'subranking, url, weight, attributes')
AttributeStore = namedtuple("AttributeStore", 'subranking, url')

post2= "/news/best-countries/articles/methodology"
r2 = dl_data(urljoin(BASEURL, post2))
attributes = get_attributes(r2)
print len(attributes)  # 9


