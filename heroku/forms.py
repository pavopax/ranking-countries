from flask_wtf import Form
from wtforms import TextField, IntegerField, TextAreaField, SubmitField 
from wtforms import validators, ValidationError, RadioField, SelectField



# get these from `../code/generate-indicator-list.py`
all_indicators = [('AG.LND.TOTL.K2', 'Land area'), ('GCI.A.01', 'Competitiveness, Institutions'), ('GCI.A.02', 'Competitiveness, Infrastructure'), ('GCI.A.03', 'Competitiveness, Macroeconomic environment'), ('GCI.A.04', 'Competitiveness, Health and primary education'), ('GCI.B.05', 'Competitiveness, Higher education and training'), ('GCI.B.06', 'Competitiveness, Goods market efficiency'), ('GCI.B.07', 'Competitiveness, Labor market efficiency'), ('GCI.B.08', 'Competitiveness, Financial market development'), ('GCI.B.09', 'Competitiveness, Technological readiness'), ('GCI.B.10', 'Competitiveness, Market size'), ('GCI.C.11', 'Competitiveness, Business sophistication '), ('GCI.C.12', 'Competitiveness, Innovation'), ('NY.GDP.PCAP.PP.CD', 'GDP per capita, PPP'), ('SI.POV.GINI', 'GINI index'), ('SP.POP.GROW', 'Population growth'), ('SP.POP.TOTL', 'Population, total'), ('ST.INT.ARVL', 'International tourism, number of arrivals'), ('ER.BDV.TOTL.XQ', 'GEF benefits index for biodiversity'), ('FB.CBK.BRCH.P5', 'Commercial bank branches'), ('IC.ISV.DURS', 'Time to resolve insolvency'), ('IC.REG.DURS', 'Time required to start a business'), ('IC.REG.PROC', 'Start-up procedures to register a business'), ('IC.TAX.PAYM', 'Tax payments'), ('IC.WRH.PROC', 'Procedures to build a warehouse'), ('SG.GEN.PARL.ZS', 'Proportion of seats held by women in national parliaments'), ('econ_optimism', 'Net economic optimism'), ('happiness', 'Net happiness'), ('hope', 'Net hope')]
optimism = [('econ_optimism', 'Net economic optimism'), ('happiness', 'Net happiness'), ('hope', 'Net hope')]
fancy = [('IC.ISV.DURS', 'Time to resolve insolvency'), ('FB.CBK.BRCH.P5', 'Commercial bank branches'),  ('IC.REG.DURS', 'Time required to start a business'), ('IC.REG.PROC', 'Start-up procedures to register a business'), ('IC.TAX.PAYM', 'Tax payments'), ('IC.WRH.PROC', 'Procedures to build a warehouse'), ('ER.BDV.TOTL.XQ', 'GEF benefits index for biodiversity'), ('SG.GEN.PARL.ZS', 'Proportion of seats held by women in national parliaments')]
main = [('AG.LND.TOTL.K2', 'Land area'), ('GCI.A.01', 'Competitiveness, Institutions'), ('GCI.A.02', 'Competitiveness, Infrastructure'), ('GCI.A.03', 'Competitiveness, Macroeconomic environment'), ('GCI.A.04', 'Competitiveness, Health and primary education'), ('GCI.B.05', 'Competitiveness, Higher education and training'), ('GCI.B.06', 'Competitiveness, Goods market efficiency'), ('GCI.B.07', 'Competitiveness, Labor market efficiency'), ('GCI.B.08', 'Competitiveness, Financial market development'), ('GCI.B.09', 'Competitiveness, Technological readiness'), ('GCI.B.10', 'Competitiveness, Market size'), ('GCI.C.11', 'Competitiveness, Business sophistication '), ('GCI.C.12', 'Competitiveness, Innovation'), ('NY.GDP.PCAP.PP.CD', 'GDP per capita, PPP'), ('SI.POV.GINI', 'GINI index'), ('SP.POP.GROW', 'Population growth'), ('SP.POP.TOTL', 'Population, total'), ('ST.INT.ARVL', 'International tourism, number of arrivals')]


class IndicatorForm(Form):
    #title = TextField("Custom Plot Title",[validators .Required("IMPORTANT NOTE: Please enter a title. <<< ")])
   

    indicator1 = SelectField('First Indicator',
                           choices = all_indicators)

    indicator2 = SelectField('Second Indicator',
                           choices = all_indicators)


    title = TextField("Add a Custom Plot Title", default="My Fancy Plot Title")


    submit = SubmitField("Submit")


class RankForm(Form):
    """Form for creating custom country ranking"""

    indicator1 = SelectField('Indicator 1', choices = main)
    indicator2 = SelectField('Indicator 2', choices = main)
    indicator3 = SelectField('Indicator 3', choices = main)
    indicator4 = SelectField('Indicator 4', choices = main)
    indicator5 = SelectField('Indicator 5', choices = main)

    optimism = SelectField('Optimism', choices = optimism)

    fancy = SelectField('Extra', choices = fancy)

    submit = SubmitField("Rank it")    
