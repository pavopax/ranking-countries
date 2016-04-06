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

## MAIN DATASETS
dfmain <- left_join(country_names, df_input0, by="Country.Code") %>%
    select(-Country.Code)
dfusn <- dfmain %>% filter(Country %in% usn60)

saveRDS(dfmain, "dfmain.rds")
saveRDS(dfusn, "dfusn.rds")
