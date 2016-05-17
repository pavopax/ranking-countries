source("header.R") 
source("functions.R")

print("MAKE WORLD BANK DATA...")
df_input0 <- read.csv("../data/8832f489-b226-41cb-ac28-59241cc84533_Data.csv",
                      stringsAsFactors=FALSE) %>%
    tbl_df %>%
    filter(Series.Code != "") %>%
    rename(Indicator=Series.Code)
## first name is weird, rename() doesn't work from command line
names(df_input0)[1] <- "Year"

df_meta0 <- read.csv("../data/8832f489-b226-41cb-ac28-59241cc84533_Country - Metadata.csv",
                     stringsAsFactors=FALSE) %>%
    tbl_df %>%
    #rename(Country.Code=X...Code) %>%
    rename(Country=Short.Name)
## first name is weird, rename() doesn't work from command line
names(df_meta0)[1] <- "Country.Code"

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

## 248, includes some groups
## 215 countries
## 60 USN countries
dffull <- left_join(country_names, df_input0, by="country.code") %>%
    select(-country.code) %>% 
    arrange(country, year, indicator) %>%
    filter(country != "")
dfall <- dffull %>% filter(!(country %in% cats))



## subset to LATEST available data, if any
## and extract indicators for which I have 'nx' data
nx <- (2/3)*length(usn60)
codes1 <- get_latest_available(dfusn) %>% group_by(indicator) %>%
    summarise(n=n()) %>% arrange(desc(n)) %>% filter(n>=nx) %>%
    .$indicator

## scale needs [,] so it doesn't return attributes
## http://jeromyanglim.tumblr.com/post/72622792597/how-to-use-scale-function-in-r-to-centre
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

wb_data <- left_join(latest_all, inv, by="indicator") %>%
    mutate(zscore=ifelse( (is.na(need_inverse) %in% FALSE),
                         -zscore_orig, zscore_orig)) %>%
    select(-need_inverse)
wb_data_plus <- left_join(latest_full, inv, by="indicator") %>%
    mutate(zscore=ifelse( (is.na(need_inverse) %in% FALSE)
                         -zscore_orig, zscore_orig)) %>%
    select(-need_inverse)

wb_entities <- df_meta0 %>% select(country, income.group, region)

wb_metadata <- attrs %>% select(indicator, label) %>%
    filter(!is.na(indicator)) %>%
    mutate(label_short=gsub("( \\(.+\\))", "", label, perl = TRUE)) %>%
    select(indicator, label_short, label) %>% 
    arrange(indicator)


print("OUTPUT TO /CACHE...")
saveRDS(wb_data, "../cache/wb_data.rds")
saveRDS(wb_data_plus, "../cache/wb_data_plus.rds")
saveRDS(wb_metadata, "../cache/wb_metadata.rds")
saveRDS(wb_entities, "../cache/wb_entities.rds")
saveRDS(usn60, "../cache/usn60.rds")
print("DONE")


