Ranking the World's Countries (working)
===============================================================================
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
Similar countries to your top choice are found using machine learning (affinity
clustering). See the notebook `/code/python-explore/affinitypropagation.ipynb`

Data explorer fits a best-fit linear regression line.

For Data details, see `/data/README.md` 

Key directories
===============================================================================

`/heroku`

contains the code for the deployed web application

`/code`

contains code to munge and explore the data [working]



Tech stack
===============================================================================
Briefly, this is a Python-Flask web application with a PostgreSQL database and bokeh-driven data explorer, all deployed to Heroku. The web page is styles with <a href="http://getbootstrap.com" target="_blank">Bootstrap</a>. <a href="{{ url_for('static', filename='ico/favicon.ico') }}" target="_blank">Favicon</a> is my own, created on <a href="https://www.fiftythree.com" target="_blank">Paper for iOS</a> and converted with <a href="http://www.favicon.cc/" target="_blank">favicon.cc</a></p>

Python tools
  * heroku deployment
  * pandas data manipulation
  * [flask web app](http://flask.pocoo.org)

Graphics
  * bokeh
  * D3, via [NVD3](https://github.com/novus/nvd3")
  * Shiny
  
Analysis
  * R
  * Python

Web 
  * [WTF-Forms](http://flask.pocoo.org/docs/0.10/patterns/wtforms/) for interactive web forms 
  * Bootstrap
  * Custom CSS, HTML tweaks (Safari console debugger was very useful!)

Database (deployed remotely to Heroku/AWS):
* Postgres <img src="https://raw.githubusercontent.com/pavopax/ranking-countries/master/heroku/static/img/ele.png" width="24px"> 

Misc
  * virtual env




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

Fantastic tutorial for deploying python/flask apps to Heroku (a bit out of date though)
  * http://blog.shea.io/lightweight-python-apps-with-flask-twitter-bootstrap-and-heroku/

HTML Table styles in flask/pandas:
* https://sarahleejane.github.io/learning/python/2015/08/09/simple-tables-in-webapps-using-flask-and-pandas-with-python.html
* https://www.smashingmagazine.com/2008/08/top-10-css-table-designs/#8-rounded-corner


Flask and forms
  * http://www.tutorialspoint.com/flask/flask_wtf.htm

