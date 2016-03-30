from flask_wtf import Form
from wtforms import TextField, IntegerField, TextAreaField, SubmitField, RadioField, SelectField

from wtforms import validators, ValidationError


#indicators = [('SE.TER.ENRR', 'Gross enrolment ratio, tertiary, both sexes (%)'), ('SE.SEC.ENRR.MA', 'Gross enrolment ratio, secondary, male (%)'), ('SE.TER.ENRR.FE', 'Gross enrolment ratio, tertiary, female (%)'), ('IQ.CPA.GNDR.XQ', 'CPIA gender equality rating (1=low to 6=high)'), ('IQ.CPA.PROP.XQ', 'CPIA property rights and rule-based governance rating (1=low to 6=high)')]

# GOOD!
#indicators = [('AG.LND.TOTL.K2':'Land Area'), ('NY.GDP.PCAP.CD', 'GDP per capita (current US$)'), ('SP.POP.TOTL', 'Population, total')]


indicators = [('AG.LND.TOTL.K2','Land Area'), ('NY.GDP.PCAP.CD', 'GDP per capita (current US$)'),
              ('SP.POP.TOTL', 'Population, total')]

class IndicatorForm(Form):
    #title = TextField("Custom Plot Title",[validators .Required("IMPORTANT NOTE: Please enter a title. <<< ")])
    title = TextField("Custom Plot Title")
   
    indicator1 = SelectField('First Indicator',
                           choices = indicators)

    indicator2 = SelectField('Second Indicator',
                           choices = indicators)

    submit = SubmitField("Create a fancy Bokeh plot!")

