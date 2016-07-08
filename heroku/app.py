import os
import pandas as pd
import numpy as np
import psycopg2
import urlparse

from math import ceil, floor

from flask import Flask, render_template, send_from_directory, request, redirect, flash, jsonify
from bokeh.plotting import figure, ColumnDataSource
from bokeh.embed import components
from bokeh.models import HoverTool
from bokeh.resources import INLINE

#from flask.ext.sqlalchemy import SQLAlchemy
from forms import IndicatorForm, RankForm  # my forms.py file
from forms_checkbox import SimpleForm  # my forms_checkbox.py file

from clustering import get_similar_countries  # my clustering.py file


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
app.rankr_vars={}

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
    """Query database, put into pandas, and display.
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

    query = """SELECT country, indicator, zscore from indicators WHERE indicator IN (%s, %s);"""
    cursor.execute(query, (ind1, ind2) )

    df=pd.DataFrame(cursor.fetchall(), columns=['country', 'indicator',
                                                'zscore'])
    df = df.pivot('country', 'indicator')
    df = df.zscore

    # get indicator labels for axes
    query = """SELECT indicator, label_short from metadata WHERE indicator IN (%s, %s);"""
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
    return render_template('graph.html', script=script, div=div)



@app.route('/rankr', methods = ['GET', 'POST'])
def rankr():
    form = RankForm()
    if request.method == 'POST':
        if form.validate() == False:
            flash('All fields are required.')
            return render_template('rankr.html', form = form)
        else:
            app.rankr_vars['i1'] = request.form['indicator1']
            app.rankr_vars['i2'] = request.form['indicator2']
            app.rankr_vars['i3'] = request.form['indicator3']
            app.rankr_vars['i4'] = request.form['indicator4']
            app.rankr_vars['i5'] = request.form['indicator5']
            app.rankr_vars['optimism'] = request.form['optimism']
            app.rankr_vars['fancy'] = request.form['fancy']
            return redirect('/result')

    elif request.method == 'GET':
        return render_template('rankr.html', form = form)


@app.route("/result")
def result():
    """Display results from /rankr. Countries are ranked by descending mean z-score
    of selected indicator choices.

    """
    # heroku/postgres setup:
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

    # OBTAIN queried data
    query = """SELECT country, indicator, zscore from indicators;"""
    cursor.execute(query)
    all_data = pd.DataFrame(cursor.fetchall(),
                            columns=[desc[0] for desc in cursor.description])
    
    query = """SELECT source, indicator, label_short from metadata;"""
    cursor.execute(query)
    all_labels = pd.DataFrame(cursor.fetchall(),
			      columns=[desc[0] for desc in cursor.description])
    conn.close()

    # GET DATA FRAMES FOR ANALYSIS
    df_wide = all_data.pivot(index='country', columns='indicator', values='zscore')
    df_wide = df_wide.fillna(0)

    choices = []
    choices.extend((app.rankr_vars['i1'], app.rankr_vars['i2'],
                    app.rankr_vars['i3'], app.rankr_vars['i4'],
                    app.rankr_vars['i5'],
                    app.rankr_vars['optimism'], app.rankr_vars['fancy']
                    ))

    df = (all_data[(all_data.indicator.isin(choices))]
          .pivot(index='country', columns='indicator', values='zscore'))
    df = df.fillna(0)
    labels = all_labels[all_labels.indicator.isin(choices)]


    N = 10
    ranked = df.mean(1).sort_values(ascending=False).head(N)
    df_ranking = pd.DataFrame({'Rank' : range(1, N+1, 1),
			    'Country' : ranked.index,
			    'Score' : ranked
                            })[['Rank', 'Country', 'Score']]

    top_country = df_ranking['Country'][0]
    similar_countries_top = get_similar_countries(df_wide, top_country)

    return render_template('result.html'
                           , rank_table=df_ranking.to_html(index=False, classes='result_table')
                           , top_country=top_country
                           , similar_countries_top=similar_countries_top
                           )


@app.route("/ranking_old")
def ranking_old():
    return render_template('original_ranking_result.html')


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


# temp: for testing fvrt_jquery.html
@app.route("/make_ranking")
def make_ranking():
    """get data from database, put into pandas, and display.
    data (indicators) are from user input in explorer()
    """

    a = request.args.get('a')
    b = request.args.get('b')

    # urlparse.uses_netloc.append("postgres")
    # url = urlparse.urlparse(os.environ["DATABASE_URL"])

    # conn = psycopg2.connect(
    #     database=url.path[1:],
    #     user=url.username,
    #     password=url.password,
    #     host=url.hostname,
    #     port=url.port
    # )

    # cursor = conn.cursor()

    # query = """SELECT , ine"""

    return jsonify(result = str(a) + str(b))

# temp: for testing fvrt_jquery.html
@app.route("/get_checkbox_values")
def get_checkbox_values():
    """get data from database, put into pandas, and display.
    data (indicators) are from user input in explorer()
    """
    a = request.args.get('a')
    return jsonify(result = str(a))


# testing
# fvrt_jquery
@app.route("/fvrt")
def fvrt():
    form_checkbox = SimpleForm()
    if form_checkbox.validate():
        print form_checkbox.indicators.data
    else:
        print form_checkbox.errors

    return render_template('fvrt_jquery.html',
                           form_checkbox=form_checkbox)


@app.route("/testing")
def testing():
    """ this is a testing page """
    return render_template('testing.html')


# launch
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
