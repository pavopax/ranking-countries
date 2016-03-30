# Ranking the World's Countries

Paul Paczuski [pavopax.com]   [AMA!] 	

Quick Start
===============================================================================

the web app (working) is at:

http://indicated.herokuapp.com

The inspiration was:

http://www.usnews.com/news/best-countries

My data is from:

http://data.worldbank.org



Contents of this file
===============================================================================
* USNWR - methodology notes
* Q3 - project idea - description
* Sources
* Programs




USNWR - methodology notes
===============================================================================
> http://www.usnews.com/news/best-countries/articles/methodology
> a marketing team, no statisticians
> at least, all data is there (transparent)

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


scores standardized to 100 for top country

## methodology notes  
> http://www.govexec.com/excellence/promising-practices/2016/01/germany-one-ranking-worlds-best-country/125272/


This is based on new research that aggregates 75 scores for everything
from culture to business and regulation, and much else besides. And to
be fair, the research is based on a global survey of some 16,000
people, asking them about their perceptions of a host of
countries. The inaugural survey was conducted by ad agency WPP, the
Wharton business school, and US News & World Report.

WPP led the survey, using a similar methodology to the one it employs
to measure consumers’ perception of company brands. Countries, like
companies, should think carefully about cultivating their brands, it
argues. This, in turn, will generate returns via foreign trade,
investment, and the like.


## notes

Some data error: Romania is abbreviated variously as ROM or ROU, so
have to be careful when merging.




Q3 - project idea - description
===============================================================================

We've all seen various rankings of the world's universities. But did
you see that US News recently ranked the world's countries?! Partially
in order to study their methodology, I will create my own ranking of
the world's countries, with the added feature that anyone using it can
customize the relative importance of the input variables to find their
own "best country." The data will be sourced via API calls from the
World Bank database, including the various development and other
indices (see data source link).

The project output will be an interactive web application showing a
few things:
* the final rankings, as an interactive, column-sortable table
* a sidebar of sorts, to create one's own ranking, by adjusting various dials
* informative visualizations, highlighting interesting features of the
dataset, including what makes a country great
* possibly, a way to order a T-shirt with "I <3 <country name>" or
  some other graphic in the front, and on the back, something like:
  "created with heroku, ruby, and git"

Some specific statistical analyses of the data will include various
correlations between features to find interesting trends, etc.

Plot descriptions (https://mighty-dawn-88782.herokuapp.com)

Plot 1 shows, for 227 countries, the association between female
parliamentary seat numbers and female educational participation. At
first sight, the trend shows a direct relationship (linear regression
line is significant), but a closer inspection with a LOESS curve shows
a curious dip. This, and similar data features, is something I would
explore further.

For Plot 2, I tried to find a funny way to present one way how a
country may become "better." So I found a spurious correlation in the
dataset: increased broadband access and homicide rate are inversely
correlated over time. The variables had different units, so I
standardized them (within each country).



Programs
===============================================================================


Sources 
===============================================================================


scratches 
===============================================================================




show GDP: various indicators *and* a text description of the analysis

remind: USNews was based on survey data and *perception*. "World names
Germany 'best country ever'" from:
`http://www.thelocal.de/20160120/germany-rated-best-overall-country-in-the-world`

