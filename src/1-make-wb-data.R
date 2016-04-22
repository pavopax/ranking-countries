## create SQL database + cached data
library(DBI)                            #first, before dplyr (bug?)
source("header.R")                      #source functions and load packages
source("R/functions.R")

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


names(df_input0) %<>% tolower
names(df_meta0) %<>% tolower
names(attrs) %<>% tolower


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

df_input0$year %<>% gsub("YR", "", .) %>% as.numeric
country_names <- df_meta0 %>% select(country.code, country)

## cats = smaller groupings from this dataset
cats <- df_meta0 %>% filter(income.group=="") %>%
    filter(long.name !="") %>% .$long.name

## ============================================================================
## MAIN DATASETS
## ============================================================================

## 248, includes "cats"
## 215 countries
## 60 USN
dffull <- left_join(country_names, df_input0, by="country.code") %>%
    select(-country.code) %>% 
    arrange(country, year, indicator) %>%
    filter(country != "")
dfall <- dffull %>% filter(!(country %in% cats))
dfusn <- dffull %>% filter(country %in% usn60)

# saveRDS(dfall, "dfall.rds")
# saveRDS(dfusn, "dfusn.rds")


## ============================================================================
## EXPLORE INDICATORS
## ============================================================================
## which year has most data?
yrs <- dfusn$year %>% unique
for (year in yrs){
    x <- dfusn %>% filter(year==year) %>% group_by(country) %>%
        na.omit %>% dim
    print(c(year, x[1]))
}

## available indicators (out of 60 countries)
indic_usn <- get_indicator_counts(dfusn)
indic_usn %>% spread(year, n)

## available indicators (out of all 248 countries)
indic_all <- get_indicator_counts(dfall)
indic_all %>% spread(year, n) %>% as.data.frame

## sum the year columns to find max # of available indicators
dfall %>% group_by(year, indicator) %>%
    na.omit() %>% summarise(n=n())%>% arrange(year, desc(n)) %>%
    spread(year, n) %>% select(-indicator) %>%
    summarise_each(funs(sum(., na.rm = TRUE)))


## "good" data availability. using 2010
## have: 31 indicators with good data for 60 USN countries
## have: 24 indicators with good data for all 248 countries
f <- (2/3)*60
series1 <- indic_usn %>% filter(year==2010 & n>=f) %>% .$indicator 
indic_usn_good <- dfusn %>% filter(year==2010 & indicator %in% series1)

f <- (2/3)*248
series2 <- indic_all %>% filter(year==2010 & n>=f) %>% .$indicator
indic_all_good <- dfall %>% filter(year==2010 & indicator %in% series2)


## subset to LATEST available data, if any
## and extract indicators for which I have 'nx' data
nx <- (2/3)*length(usn60)
codes1 <- get_latest_available(dfusn) %>% group_by(indicator) %>%
    summarise(n=n()) %>% arrange(desc(n)) %>% filter(n>=nx) %>%
    .$indicator

## scale needs [,] so it doesn't return attributes
## http://jeromyanglim.tumblr.com/post/72622792597/how-to-use-scale-function-in-r-to-centre
latest_usn <- get_latest_available(dfusn) %>%
    filter(indicator %in% codes1) %>%
    group_by(indicator) %>%
    mutate(zscore_orig=scale(value, center = TRUE, scale=TRUE)[,]) %>%
    ungroup()
latest_all <- get_latest_available(dfall) %>%
    filter(indicator %in% codes1) %>%
    group_by(indicator) %>%
    mutate(zscore_orig=scale(value, center = TRUE, scale=TRUE)[,]) %>%
    ungroup()
latest_full <- get_latest_available(dffull) %>%
    filter(indicator %in% codes1) %>%
    group_by(indicator) %>%
    mutate(zscore_orig=scale(value, center = TRUE, scale=TRUE)[,]) %>%
    ungroup()


## INVERT "negative" variables to make them positive
inv <- attrs %>% select(indicator, need_inverse) %>% na.omit

latest_usn <- left_join(latest_usn, inv, by="indicator") %>%
    mutate(zscore=ifelse( (is.na(need_inverse) %in% FALSE),
                         -zscore_orig, zscore_orig)) %>%
    select(-need_inverse)
latest_all <- left_join(latest_all, inv, by="indicator") %>%
    mutate(zscore=ifelse( (is.na(need_inverse) %in% FALSE),
                         -zscore_orig, zscore_orig)) %>%
    select(-need_inverse)
latest_full <- left_join(latest_full, inv, by="indicator") %>%
    mutate(zscore=ifelse( (is.na(need_inverse) %in% FALSE)
                         -zscore_orig, zscore_orig)) %>%
    select(-need_inverse)

## check
latest_usn %>%
    filter(indicator=="IC.BUS.EASE.XQ") %>%
    arrange(zscore_orig)


## ============================================================================
## EXPLORE potential classification (Y) variables
## ============================================================================
cats

classes <- df_meta0 %>% select(country, income.group, region)




## ============================================================================
## OUTPUT CACHED DATASETS
## ============================================================================
codes <- attrs %>% select(indicator, label) %>%
    na.omit %>%
    mutate(label_short=gsub("( \\(.+\\))", "", label, perl = TRUE)) %>%
    select(indicator, label_short, label) %>% 
    arrange(indicator)

write_my_csv("latest_usn")
write_my_csv("latest_all")
write_my_csv("latest_full")
write_my_csv("classes")
write_my_csv("attrs")
write_my_csv("codes")


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
dbWriteTable(conn=con, name="usn", value=as.data.frame(latest_usn),
             overwrite=TRUE)
dbWriteTable(conn=con, name="codes", value=as.data.frame(codes),
             overwrite=TRUE)
#dbWriteTable(conn=con, name="test", value=as.data.frame(latest_usn[1:40,]))
dbDisconnect(RPostgres::Postgres(), dbname="wb_indicators")

