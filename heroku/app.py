import os
from flask import Flask, render_template, send_from_directory, request, redirect
from Quandl import Quandl
import time
from bokeh.plotting import figure
from bokeh.embed import components


# initialization
app = Flask(__name__)
app.config.update(
    DEBUG=True,
)


app.vars={}

auth_tok = "ad1xk_Hf1MdMZpF72a_X"




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

@app.route("/explorer", methods=['GET', 'POST'])
def explorer():
    if request.method=='GET':
        return render_template('explorer.html')
    else:
        app.vars['stock'] = request.form['ticker']
        return redirect('/graph')



@app.route('/graph')
def graph():
    stock = app.vars['stock']
    stockq = "/".join(("WIKI", stock))
    data = Quandl.get(stockq, rows=20, authtoken=auth_tok, returns="pandas")
    df = data[['Close']]
    p = figure(width=700, height=500, title=stock, x_axis_type='datetime')
    p.circle(x=df.index, y=df[['Close']])
    script, div = components(p)
    return render_template('graph.html', script=script, div=div)


@app.route("/history")
def history():
    return render_template('history.html')

@app.route("/week1")
def week1():
    return render_template('week1.html')


# launch
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)

    







