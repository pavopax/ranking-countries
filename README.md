# Ranking the World's Countries
Paul Paczuski [pavopax.com](http://pavopax.github.io)   [AMA!] 	

The web app (working) is at:
* http://indicated.herokuapp.com

The inspiration was:
* http://www.usnews.com/news/best-countries

My data is from:
* http://data.worldbank.org
* http://reports.weforum.org/global-competitiveness-report-2014-2015/


Toolkit 
===============================================================================

heroku

virtual env

python

* `app.py` includes my custom module/class `IndicatorForm`

Postgres <img src="https://raw.githubusercontent.com/pavopax/ranking-countries/master/heroku/static/img/ele.png" width="24px"> database
*  deployed remotely, interacts with Flask (see the [Data Explorer](http://indicated.herokuapp.com/explorer) )




USNWR - methodology notes
===============================================================================
http://www.usnews.com/news/best-countries/articles/methodology

65 country attributes, grouped into:
* Adventure
* Citizenship
* Cultural Influence
* Entrepreneurship
* Heritage
* Movers
* Open for Business
* Power
* Quality of Life

Sources 
===============================================================================
More on some CPIA indicators:
* http://data.worldbank.org/data-catalog/CPIA

