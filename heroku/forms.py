from flask_wtf import Form
from wtforms import TextField, IntegerField, TextAreaField, SubmitField, RadioField, SelectField

from wtforms import validators, ValidationError


#indicators = [('SE.TER.ENRR', 'Gross enrolment ratio, tertiary, both sexes (%)'), ('SE.SEC.ENRR.MA', 'Gross enrolment ratio, secondary, male (%)'), ('SE.TER.ENRR.FE', 'Gross enrolment ratio, tertiary, female (%)'), ('IQ.CPA.GNDR.XQ', 'CPIA gender equality rating (1=low to 6=high)'), ('IQ.CPA.PROP.XQ', 'CPIA property rights and rule-based governance rating (1=low to 6=high)')]

# GOOD!
#indicators = [('AG.LND.TOTL.K2':'Land Area'), ('NY.GDP.PCAP.CD', 'GDP per capita (current US$)'), ('SP.POP.TOTL', 'Population, total')]


# TODO: get these from DB
indicators = [('AG.LND.TOTL.K2', 'Land area (sq. km)'),
              ('EN.POP.DNST', 'Population density (people per sq. km of land area)'),
              ('ER.BDV.TOTL.XQ', 'GEF benefits index for biodiversity (0 = no biodiversity potential to 100 = maximum)'),
              ('ST.INT.ARVL', 'International tourism, number of arrivals'),
              ('ST.INT.RCPT.XP.ZS', 'International tourism, receipts (% of total exports)'),
              ('SE.ADT.LITR.ZS', 'Literacy rate, adult total (% of people ages 15 and above)'),
              ('IC.BUS.NDNS.ZS', 'New business density (new registrations per 1,000 people ages 15-64)'),
              ('FB.CBK.BRCH.P5', 'Commercial bank branches (per 100,000 adults)'),
              ('SL.TLF.TERT.ZS', 'Labor force with tertiary education (% of total)'),
              ('SL.TLF.SECO.ZS', 'Labor force with secondary education (% of total)'),
              ('TX.VAL.TECH.CD', 'High-technology exports (current US$)'),
              ('TX.VAL.TECH.MF.ZS', 'High-technology exports (% of manufactured exports)'),
              ('IC.BUS.DISC.XQ', 'Business extent of disclosure index (0=less disclosure to 10=more disclosure)'),
              ('IS.RRS.GOOD.MT.K6', 'Railways, goods transported (million ton-km)'),
              ('IS.AIR.PSGR', 'Air transport, passengers carried'),
              ('IC.LGL.CRED.XQ', 'Strength of legal rights index (0=weak to 12=strong)'),
              ('IC.REG.DURS', 'Time required to start a business (days)'),
              ('IC.BUS.EASE.XQ', 'Ease of doing business index (1=most business-friendly regulations)'),
              ('NV.IND.MANF.ZS', 'Manufacturing, value added (% of GDP)'),
              ('NY.GDP.MKTP.CD', 'GDP (current US$)'),
              ('NY.GDP.PCAP.CD', 'GDP per capita (current US$)'),
              ('NY.GDP.PCAP.PP.CD', 'GDP per capita, PPP (current international $)'),
              ('GC.TAX.YPKG.ZS', 'Taxes on income, profits and capital gains (% of total taxes)'),
              ('SP.POP.GROW', 'Population growth (annual %)'),
              ('MS.MIL.XPND.CN', 'Military expenditure (current LCU)'),
              ('MS.MIL.XPND.GD.ZS', 'Military expenditure (% of GDP)'),
              ('SL.UEM.TOTL.ZS', 'Unemployment, total (% of total labor force) (modeled ILO estimate)'),
              ('FP.CPI.TOTL.ZG', 'Inflation, consumer prices (annual %)'),
              ('SI.POV.GINI', 'GINI index (World Bank estimate)'),
              ('SH.MED.BEDS.ZS', 'Hospital beds (per 1,000 people)')]



class IndicatorForm(Form):
    #title = TextField("Custom Plot Title",[validators .Required("IMPORTANT NOTE: Please enter a title. <<< ")])
   

    indicator1 = SelectField('First Indicator',
                           choices = indicators)

    indicator2 = SelectField('Second Indicator',
                           choices = indicators)



    title = TextField("Add a Custom Plot Title", default="My Fancy Plot Title")


    submit = SubmitField("Submit")

