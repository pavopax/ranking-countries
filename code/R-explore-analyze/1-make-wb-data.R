source("header.R")

df_input0 <- read.csv("../../data/8832f489-b226-41cb-ac28-59241cc84533_Data.csv",
                      stringsAsFactors=FALSE) %>%
    tbl_df %>% rename(Year=X...Time.Code) %>% filter(Series.Code != "")
df_meta0 <- read.csv("../../data/8832f489-b226-41cb-ac28-59241cc84533_Country - Metadata.csv",
                     stringsAsFactors=FALSE) %>%
    tbl_df %>% rename(Country.Code=X...Code)

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
country_names <- df_meta0 %>% select(Country.Code, Short.Name) %>%
    rename(Country=Short.Name)

## ============================================================================
## MAIN DATASETS
## ============================================================================
dfall <- left_join(country_names, df_input0, by="Country.Code") %>%
    select(-Country.Code) %>%
    arrange(Country, Year, Series.Code)
dfusn <- dfall %>% filter(Country %in% usn60)

saveRDS(dfall, "dfall.rds")
saveRDS(dfusn, "dfusn.rds")


## ============================================================================
## EXPLORE
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
indic_all %>% spread(Year, n)

## sum the year columns to find max # of available indicators
dfall %>% group_by(Year, Series.Code) %>%
    na.omit() %>% summarise(n=n())%>% arrange(Year, desc(n)) %>%
    spread(Year, n) %>% select(-Series.Code) %>%
    summarise_each(funs(sum(., na.rm = TRUE)))


## subset to "good" data availability. using 2010
## have: 31 indicators with good data for 60 USN countries
## have: 24 indicators with good data for all 248 countries
f <- (2/3)*60
series1 <- indic_usn %>% filter(Year==2010 & n>=f) %>% .$Series.Code 
indic_usn_good <- dfusn %>% filter(Year==2010 & Series.Code %in% series1)

f <- (2/3)*248
series2 <- indic_all %>% filter(Year==2010 & n>=f) %>% .$Series.Code
indic_all_good <- dfall %>% filter(Year==2010 & Series.Code %in% series2)

## ============================================================================
## FINAL DATASETS
## ============================================================================
write.csv(indic_usn_good, file="../../data/indicators_usn_good.csv")
write.csv(indic_all_good, file="../../data/indicators_all_good.csv")


    






