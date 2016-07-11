Ranking the World's Countries (working)
===============================================================================

*STATUS NOTE: app is broken as of July 11, 2016. should be fixed in 1-2 days*

The web app is at:

* http://ranking-countries.herokuapp.com

The inspiration was:

* http://www.usnews.com/news/best-countries

The data is from:

* [The World Bank - Indicators](http://data.worldbank.org)
* [World Economic Forum - Global Competitiveness Index](http://reports.weforum.org/global-competitiveness-report-2014-2015/)
* [WIN/Gallup International - End of the Year Survey](http://www.wingia.com/en/services/end_of_year_survey_2015/global_regional_results/9/53/)

See below for [details](#details) and [tech stack](#tech-stack)

Details
===============================================================================
Similar countries to your top choice are found using Machine learning (affinity clustering).

For Data details, see `/data/README.md` 

`/heroku`

contains the code for the deployed web app

`/code`

contains code to explore and munge data



Tech stack
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

Resources
===============================================================================

HTML Table styles in flask/pandas:
* https://sarahleejane.github.io/learning/python/2015/08/09/simple-tables-in-webapps-using-flask-and-pandas-with-python.html
* https://www.smashingmagazine.com/2008/08/top-10-css-table-designs/#8-rounded-corner


