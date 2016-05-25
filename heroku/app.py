import os
import wbdata
import datetime
import pandas as pd
import numpy as np
import psycopg2
import urlparse

from math import ceil, floor

from flask import Flask, render_template, send_from_directory, request, redirect, flash, jsonify
from bokeh.plotting import figure, ColumnDataSource
from bokeh.embed import components
from bokeh.models import HoverTool, BoxSelectTool
from bokeh.resources import INLINE

#from flask.ext.sqlalchemy import SQLAlchemy
import sqlalchemy
from forms import IndicatorForm  # my forms.py file

# initialization
app = Flask(__name__)

# https://realpython.com/blog/python/flask-by-example-part-1-project-setup/
# app.config.from_object(os.environ['APP_SETTINGS'])
# print(os.environ['APP_SETTINGS'])

app.config.update(
    DEBUG=True,
)


# for csrf stuff (?)
# for flask-wtf (forms.py)
app.secret_key = 'development key'

# for passing some vars from user input
app.vars={}

@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'),
                               'ico/favicon.ico')


@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404


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

    query = """SELECT country, indicator, zscore from usn WHERE indicator IN (%s, %s);"""
    cursor.execute(query, (ind1, ind2) )

    df=pd.DataFrame(cursor.fetchall(), columns=['country', 'indicator',
                                                'zscore'])
    df = df.pivot('country', 'indicator')
    df = df.zscore

    # get indicator labels for axes
    query = """SELECT indicator, label from codes WHERE indicator IN (%s, %s);"""
    cursor.execute(query, (ind1, ind2) )
    labs = dict(cursor.fetchall())

    conn.commit();
    conn.close();

    hover = HoverTool(
        tooltips=[
            ("Country", "@country"),
            (labs[ind1], "$x"),
            (labs[ind2], "$y"),
            
        ]
    )

    data_source = ColumnDataSource(data=df)

    # add regression line
    # to prevent errors, use idx:
    idx = np.isfinite(df[ind1]) & np.isfinite(df[ind2])
    xx = df[ind1].ix[idx]
    yy = df[ind2].ix[idx]

    regression = np.polyfit(xx, yy, 1)
    r_x, r_y = zip(*((i, i*regression[0] + regression[1]) for i in range(
        int(floor(min( min(xx), min(yy) ))),
        int(ceil(max( max(xx), max(yy)))+1)
        )))

    # NOTE: use `labs` to correctly match label with indicator,
    # and preserve user-specified indicator order
    p = figure(width=700, height=500, title = app.vars['title'],
	       x_axis_label = labs[ind1], y_axis_label = labs[ind2],
               tools=[hover])
    p.circle(x=df[ind1], y=df[ind2], size=10,
	     color="navy", alpha=0.5, source=data_source)
    p.line(r_x, r_y, color="coral", line_width=3)
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


# temp: for testing fvrt.html
@app.route("/add_numbers")
def add_numbers():
    a = request.args.get('a', 0, type=int)
    b = request.args.get('b', 0, type=int)
    return jsonify(result = a+b)


# temp: for testing polynomial.html
def getitem(obj, item, default):
    if item not in obj:
        return default
    else:
        return obj[item]
        

# temp: for testing polynomial.html
colors = {
    'Black': '#000000',
    'Red':   '#FF0000',
    'Green': '#00FF00',
    'Blue':  '#0000FF',
}

@app.route("/polynomial")
def polynomial():
    """ embed simple polynomial chart
    """
    args = request.args
    form = IndicatorForm()

    # get all the form arguments in the url with defaults
    color = colors[getitem(args, 'color', 'Black')]
    _from = int(getitem(args, '_from', 0))
    to = int(getitem(args, 'to', '10'))

    # create a polynomial line graph
    x = list(range(_from, to+1))
    fig = figure(title="Polynomials!")
    fig.line(x, [i ** 3 for i in x], color=color, line_width=2)

    # Configure resources to include BokehJS inline in the document
    # for more details, see:
    #   http://bokeh.pydata.org/en/latest/docs/reference/resources_embedding.html#bokeh-embed
    js_resources = INLINE.render_js()
    css_resources = INLINE.render_css()

    # for more details, see:
    #   http://bokeh.pydata.org/en/latest/docs/user_guide/embedding.html#components
    script, div = components(fig, INLINE)

    return render_template('temp_embed.html',
                           plot_script=script, plot_div=div,
                           js_resources=js_resources,
                           css_resources=css_resources,
                           color=color, _from=_from, to=to,
                           form=form)


@app.route("/fvrt")
def fvrt():
    return render_template('fvrt.html')

@app.route("/testing")
def testing():
    """ this is a testing page """
    return render_template('testing.html')


# launch
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
