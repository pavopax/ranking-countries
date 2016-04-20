import os
import wbdata
import time
import datetime
import pandas as pd
import numpy as np
import psycopg2
import urlparse

from flask import Flask, render_template, send_from_directory, request,redirect, flash
from bokeh.plotting import figure
from bokeh.embed import components
from flask.ext.sqlalchemy import SQLAlchemy

# my forms.py file
from forms import IndicatorForm


# initialization
app = Flask(__name__)
app.config.update(
    DEBUG=True,
)




# for csrf stuff (?)
# for flask-wtf (forms.py)
app.secret_key = 'development key'

# for passing some vars from user input
app.vars={}


# controllers

@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'),
                               'ico/favicon.ico')

@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404


# lead main page to index
@app.route('/')
def main():
  return redirect('/index')


@app.route("/index")
def index():
    return render_template('index.html')



@app.route('/explorer', methods = ['GET', 'POST'])
def explorer():
    form = IndicatorForm()
   
    if request.method == 'POST':
        if form.validate() == False:
            flash('All fields are required.')
            return render_template('explorer.html', form = form)
        else:
            app.vars['i1'] = request.form['indicator1']
            app.vars['i2'] = request.form['indicator2']
            app.vars['title'] = request.form['title']
            return redirect('/graph')
    elif request.method == 'GET':
        return render_template('explorer.html', form = form)


# @app.route('/explorer', methods = ['GET', 'POST'])
# def contact():
#     form = IndicatorForm()
   
#     if request.method == 'POST':
#         if form.validate() == False:
#             flash('All fields are required.')
#             return render_template('explorer.html', form = form)
#         else:
#             return redirect('/graph')
#     elif request.method == 'GET':
#         return render_template('explorer.html', form = form)


# @app.route("/explorer", methods=['GET', 'POST'])
# def explorer():
#     if request.method=='GET':
#         return render_template('explorer.html')
#     else:
#         app.vars['ix'] = request.form['indicator']
#         return redirect('/graph')

# @app.route("/explorer", methods=['GET', 'POST'])
# def explorer():
#     if request.method=='GET':
#         return render_template('explorer.html')
#     else:
#         app.vars['ix'] = request.form['indicator']
#         return redirect('/graph')


@app.route('/graph')
def graph():

    ## TODO: automate this.
    ## select USN's top 60 countries (scraping is DONE)
    countries = ["ARG", "AUS", "AUT", "AZE", "BGR", "BOL", "BRA", "CAN", "CHL", "CHN", "COL", "CRI", "CZE", "DEU", "DNK", "DOM", "DZA", "EGY", "ESP", "FRA", "GBR", "GRC", "GTM", "HUN", "IDN", "IND", "IRL", "IRN", "ISR", "ITA", "JOR", "JPN", "KAZ", "KOR", "LKA", "LUX", "MAR", "MEX", "MYS", "NGA", "NLD", "NZL", "PAK", "PAN", "PER", "PHL", "PRT", "ROU", "RUS", "SAU", "SGP", "SWE", "THA", "TUN", "TUR", "UKR", "URY", "USA", "VNM", "ZAF"]

    # set up the indicator I want
    # (just build up the dict if you want more than one)
    oldindicators = {'NY.GDP.PCAP.CD': 'GDP per capita',
                  'SI.POV.GINI':'GINI',
                  'AG.LND.TOTL.K2':'Land Area'}

    ind1 = app.vars['i1']
    ind2 = app.vars['i2']
    #landarea = 'AG.LND.TOTL.K2'
    keys = [ind1] + [ind2] 
    vals = [ind1] + [ind2] 

    indicators = dict(zip(keys, vals))
 
    #TODO edit date. using some recent date for now
    dates = datetime.datetime(2001, 1, 1, 0, 0)

    df0 = wbdata.get_dataframe(indicators, country=countries, data_date=dates,
                           convert_date=False)

    # standardize the 2 indicators, but transform the land area (3rd column)
    df1 = df0.ix[:,0:2].apply(lambda x: (x - np.min(x)) /(np.max(x)-np.min(x)))
    # df2 = df0.ix[:,2]
    # df2 = 5*np.log(df2)/((np.log(df2.max()))-(np.log(df2.min())+5)).astype(
    #     np.float64)

    df = df1
    # TODO: use HoverTools (SEE ipy nb)
    ptitle=str(df.columns[1]) + " vs. " + str(
        df.columns[0]) +" (standardized values)"
    p = figure(width=700, height=500, title = app.vars['title'],
               x_axis_label = df.columns[1], y_axis_label = df.columns[0])
    p.circle(x=df[df.columns[1]], y=df[df.columns[0]],
             size=10, color="navy", alpha=0.5)

    script, div = components(p)
    return render_template('graph.html', script=script, div=div,
                           i1=ind1,i2 = ind2)


@app.route("/ranking")
def ranking():
    return render_template('ranking.html')

@app.route("/indicators")
def indicators():
    return render_template('indicators.html')

@app.route("/insights")
def insights():
    return render_template('insights.html')


@app.route("/history")
def history():
    return render_template('history.html')


@app.route("/week1")
def week1():
    return render_template('week1.html')


@app.route("/testing")
def testing():
    # https://devcenter.heroku.com/articles/heroku-postgresql#connecting-in-python
    urlparse.uses_netloc.append("postgres")
    url = urlparse.urlparse(os.environ["DATABASE_URL"])

    conn = psycopg2.connect(
        database=url.path[1:],
        user=url.username,
        password=url.password,
        host=url.hostname,
        port=url.port
    )

    # http://stackoverflow.com/questions/31473457/converting-query-results-into-dataframe-in-python
    # QUOTES ARE important: """ vs ' vs "
    # http://www.postgresql.org/docs/current/static/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS
    #query = """SELECT "Country", "Indicator", "zscore" from usn"""
    query = """SELECT "Country", "Indicator", "zscore" from usn WHERE "Indicator"
    IN ('AG.LND.TOTL.K2', 'SI.POV.GINI');"""

    cursor = conn.cursor()
    cursor.execute(query)

    df=pd.DataFrame(cursor.fetchall(), columns=['Country', 'Indicator', 'zscore'])
    df = df.pivot('Country', 'Indicator')
    df = df.zscore

    conn.commit();
    conn.close();

    p = figure(width=700, height=500, title = 'my title',
	       x_axis_label = df.columns[1], y_axis_label = df.columns[0])
    p.circle(x=df[df.columns[1]], y=df[df.columns[0]], size=10,
	     color="navy", alpha=0.5)

    script, div = components(p)
    return render_template('testing.html',  script=script, div=div)

# launch
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)

    







