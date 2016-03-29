# scrapte USN's top 60 countries
import requests
from bs4 import BeautifulSoup   # html parser
from collections import namedtuple # like a dict
from urlparse import urljoin 

def dl_data(url):
    print "Download data..."
    r = requests.get(url)
    print "Done."
    return r


def get_country_data(item):
    name = item.text
    url = item['href']
    return CountryStore(name=name, url=url)

BASEURL = "http://www.usnews.com"
post = "/news/best-countries/data-explorer"

CountryStore = namedtuple("CountryStore", 'name, url')

r = dl_data(urljoin(BASEURL, post))
soup = BeautifulSoup(r.text)
divs = soup.find_all('div', attrs={'class': 'small-12 column'})
p = divs[1].select('p')[0]      # only one exists

country_info =  [get_country_data(c) for c in p.select('a') if get_country_data(c) is not None]
