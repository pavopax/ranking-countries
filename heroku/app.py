import os
import wbdata
import datetime
import pandas as pd
import numpy as np
import psycopg2
import urlparse

from flask import Flask, render_template, send_from_directory, request,redirect, flash
from bokeh.plotting import figure
from bokeh.embed import components
#from flask.ext.sqlalchemy import SQLAlchemy

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


@app.route('/graph')
def graph():
    """get data from database, put into pandas, and display.
    data (indicators) are from user input in explorer()
    """
    urlparse.uses_netloc.append("postgres")
    url = urlparse.urlparse(os.environ["DATABASE_URL"])

    conn = psycopg2.connect(
        database=url.path[1:],
        user=url.username,
        password=url.password,
        host=url.hostname,
        port=url.port
    )

    cursor = conn.cursor()

    # from user input
    ind1 = app.vars['i1']
    ind2 = app.vars['i2']

    query = """SELECT "Country", "Indicator", "zscore" from usn WHERE "Indicator" IN (%s, %s);"""
    cursor.execute(query, (ind1, ind2) )

    df=pd.DataFrame(cursor.fetchall(), columns=['Country', 'Indicator',
                                                'zscore'])
    df = df.pivot('Country', 'Indicator')
    df = df.zscore

    # get indicator labels for axes
    query = """SELECT "Indicator", "Label" from codes WHERE "Indicator" IN (%s, %s);"""
    cursor.execute(query, (ind1, ind2) )
    labs = cursor.fetchall()

    conn.commit();
    conn.close();

    p = figure(width=700, height=500, title = app.vars['title'],
	       x_axis_label = labs[0][1], y_axis_label = labs[1][1])
    p.circle(x=df[df.columns[0]], y=df[df.columns[1]], size=10,
	     color="navy", alpha=0.5)

    p.xaxis.axis_label_text_font_size = "10pt"
    p.yaxis.axis_label_text_font_size = "10pt"

    script, div = components(p)
    return render_template('graph.html', script=script, div=div,
                           i1=ind1, i2=ind2)


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
    """ this is a testing page """
    return render_template('testing.html')

# launch
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)

    







