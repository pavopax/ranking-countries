## create SQL database + cached data
library(DBI)                            #first, before dplyr (bug?)
source("header.R")                      #source functions and load packages


df_input0 <- read.csv("../data/8832f489-b226-41cb-ac28-59241cc84533_Data.csv",
                      stringsAsFactors=FALSE) %>%
    tbl_df  %>% filter(Series.Code != "") %>%
    rename(Year=X...Time.Code, Indicator=Series.Code)
df_meta0 <- read.csv("../data/8832f489-b226-41cb-ac28-59241cc84533_Country - Metadata.csv",
                     stringsAsFactors=FALSE) %>%
    tbl_df %>% rename(Country.Code=X...Code) %>%
    rename(Country=Short.Name)

attrs <- read.csv("../data/map-categories-attributes-final.csv",
                  stringsAsFactors=FALSE, na.strings="") %>% tbl_df


## TODO: get from scrape output
usn60 <- c("Algeria", "Argentina", "Australia", "Austria",
           "Azerbaijan", "Bolivia", "Brazil", "Bulgaria", "Canada",
           "Chile", "China", "Colombia", "Costa Rica",
           "Czech Republic", "Denmark", "Dominican Republic",
           "Egypt", "France", "Germany", "Greece", "Guatemala",
           "Hungary", "India", "Indonesia", "Iran", "Ireland",
           "Israel", "Italy", "Japan", "Jordan", "Kazakhstan",
           "Luxembourg", "Malaysia", "Mexico", "Morocco",
           "Netherlands", "New Zealand", "Nigeria", "Pakistan",
           "Panama", "Peru", "Philippines", "Portugal", "Romania",
           "Russia", "Saudi Arabia", "Singapore", "South Africa",
           "South Korea", "Spain", "Sri Lanka", "Sweden",
           "Thailand", "Tunisia", "Turkey", "Ukraine",
           "United Kingdom", "United States", "Uruguay", "Vietnam") %>%
    gsub("South Korea", "Korea", .) 

df_input0$Year %<>% gsub("YR", "", .) %>% as.numeric
country_names <- df_meta0 %>% select(Country.Code, Country)

## cats = smaller groupings from this dataset
cats <- df_meta0 %>% filter(Income.Group=="") %>%
    filter(Long.Name !="") %>% .$Long.Name

## ============================================================================
## MAIN DATASETS
## ============================================================================

## 248, includes "cats"
## 215 countries
## 60 USN
dffull <- left_join(country_names, df_input0, by="Country.Code") %>%
    select(-Country.Code) %>% 
    arrange(Country, Year, Indicator) %>%
    filter(Country != "")
dfall <- dffull %>% filter(!(Country %in% cats))
dfusn <- dffull %>% filter(Country %in% usn60)

# saveRDS(dfall, "dfall.rds")
# saveRDS(dfusn, "dfusn.rds")


## ============================================================================
## EXPLORE INDICATORS
## ============================================================================
## which year has most data?
yrs <- dfusn$Year %>% unique
for (year in yrs){
    x <- dfusn %>% filter(Year==year) %>% group_by(Country) %>%
        na.omit %>% dim
    print(c(year, x[1]))
}

## available indicators (out of 60 countries)
indic_usn <- get_indicator_counts(dfusn)
indic_usn %>% spread(Year, n)

## available indicators (out of all 248 countries)
indic_all <- get_indicator_counts(dfall)
indic_all %>% spread(Year, n) %>% as.data.frame

## sum the year columns to find max # of available indicators
dfall %>% group_by(Year, Indicator) %>%
    na.omit() %>% summarise(n=n())%>% arrange(Year, desc(n)) %>%
    spread(Year, n) %>% select(-Indicator) %>%
    summarise_each(funs(sum(., na.rm = TRUE)))


## "good" data availability. using 2010
## have: 31 indicators with good data for 60 USN countries
## have: 24 indicators with good data for all 248 countries
f <- (2/3)*60
series1 <- indic_usn %>% filter(Year==2010 & n>=f) %>% .$Indicator 
indic_usn_good <- dfusn %>% filter(Year==2010 & Indicator %in% series1)

f <- (2/3)*248
series2 <- indic_all %>% filter(Year==2010 & n>=f) %>% .$Indicator
indic_all_good <- dfall %>% filter(Year==2010 & Indicator %in% series2)


## subset to LATEST available data, if any
## and extract indicators for which I have 'nx' data
nx <- (2/3)*length(usn60)
codes1 <- get_latest_available(dfusn) %>% group_by(Indicator) %>%
    summarise(n=n()) %>% arrange(desc(n)) %>% filter(n>=nx) %>%
    .$Indicator

## scale needs [,] so it doesn't return attributes
## http://jeromyanglim.tumblr.com/post/72622792597/how-to-use-scale-function-in-r-to-centre
latest_usn <- get_latest_available(dfusn) %>%
    filter(Indicator %in% codes1) %>%
    group_by(Indicator) %>%
    mutate(zscore=scale(Value, center = TRUE, scale=TRUE)[,]) %>%
    ungroup()

latest_all <- get_latest_available(dfall) %>%
    filter(Indicator %in% codes1) %>%
    group_by(Indicator) %>%
    mutate(zscore=scale(Value, center = TRUE, scale=TRUE)[,]) %>%
    ungroup()

latest_full <- get_latest_available(dffull) %>%
    filter(Indicator %in% codes1) %>%
    group_by(Indicator) %>%
    mutate(zscore=scale(Value, center = TRUE, scale=TRUE)[,]) %>%
    ungroup()


## INVERT "negative" variables to make them positive
inv <- attrs %>% select(Indicator, need_inverse) %>% na.omit

latest_usn <- left_join(latest_usn, inv, by="Indicator") %>%
    mutate(zscore_=ifelse( (is.na(need_inverse) %in% FALSE), -zscore, zscore))

latest_all <- left_join(latest_all, inv, by="Indicator") %>%
    mutate(zscore_=ifelse( (is.na(need_inverse) %in% FALSE), -zscore, zscore))

latest_full <- left_join(latest_full, inv, by="Indicator") %>%
    mutate(zscore_=ifelse( (is.na(need_inverse) %in% FALSE), -zscore, zscore))

## check
latest_usn %>%
    filter(Indicator=="IC.BUS.EASE.XQ") %>%
    arrange(zscore)


## ============================================================================
## EXPLORE potential classification (Y) variables
## ============================================================================
cats

classes <- df_meta0 %>% select(Country, Income.Group, Region)




## ============================================================================
## OUTPUT CACHED DATASETS
## ============================================================================
codes_only <- attrs %>% select(Indicator, Label) %>%
    na.omit %>% arrange(Indicator)

## write_my_csv("latest_usn")
## write_my_csv("latest_all")
## write_my_csv("latest_full")
## write_my_csv("classes")
## write_my_csv("attrs")
## write_my_csv("codes_only")


## ============================================================================
## CREATE DATABASE
## ============================================================================

## library("sqldf")
## db <- dbConnect(SQLite(), dbname="../db/wb.sqlite")
## dbWriteTable(conn=con, name="latest_usn", value=as.data.frame(latest_usn))

## connect to python:
# https://devcenter.heroku.com/articles/heroku-postgresql#provisioning-the-add-on



## need to have open Postgres.app 
con <- dbConnect(RPostgres::Postgres(), dbname="wb_indicators")
dbWriteTable(conn=con, name="usn", value=as.data.frame(latest_usn))
dbWriteTable(conn=con, name="codes", value=as.data.frame(codes_only))
#dbWriteTable(conn=con, name="test", value=as.data.frame(latest_usn[1:40,]))
dbDisconnect(RPostgres::Postgres(), dbname="wb_indicators")

