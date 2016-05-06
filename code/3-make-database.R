library(DBI)
source("header.R")
source("functions.R")

usn60 <- readRDS("../cache/usn60.rds")

wb_data <- readRDS("../cache/wb_data.rds")
wb_metadata <- readRDS("../cache/wb_metadata.rds")
wb_entities <- readRDS("../cache/wb_entities.rds")

wef_data <- readRDS("../cache/wef_data.rds")
wef_metadata <- readRDS("../cache/wef_metadata.rds")
wef_entities <- readRDS("../cache/wef_entities.rds")


## ============================================================================
## DATA SUMMARIES
## ============================================================================
wb_data %>% dim
wef_data %>% dim

wb_data$indicator %>% unique %>% length
wef_data$indicator %>% unique %>% length

wb_data$country %>% unique %>% length
wef_data$country %>% unique %>% length


## ============================================================================
## STANDARADIZE AND MERGE THE 2 DATASETS (WB + WEF)
## ============================================================================
indicators <- bind_rows(
    wef_data,
    wb_data %>% select(country, indicator, value, zscore)
) %>% arrange(country, indicator)


indicators$country %<>%
    iconv(., "latin1", "ASCII", sub="") %>%
    gsub("\\b\\.\\b", " ", ., perl=TRUE) %>%
    gsub(".*Ivoire*", "Cote d'Ivoire", .) %>%
    gsub(".*Hong Kong.*", "Hong Kong", .) %>%
    gsub(".*Iran.*", "Iran", .) %>%
    gsub(".*Macedonia.*", "Macedonia", .) %>%
    gsub(".*Russia.*", "Russia", .) %>%
    gsub(".*Leste.*", "Timor Leste", .) %>%
    gsub("Korea..Rep", "Korea", .) %>% 
    gsub("Korea..Rep", "Korea", .) %>%
    gsub("Brunei Darussalam", "Brunei", .)


## THE METADATA
wef_metadata$source <- "WEF"
wb_metadata$source <- "WB"

## to match label_short in WB
wef_metadata$label_short <- gsub("( \\(.+\\))", "", wef_metadata$label) %>%
    gsub("(,.+)", "", .) %>% 
    gsub("\\*", "", .)

metadata <- bind_rows(wef_metadata, wb_metadata)

## TODO: standardize the entities
## c() the entities with my indicator$countries,
## and then apply strategy from indicator$countries


## ============================================================================
## SAVE TO DATABASE
## ============================================================================
con <- dbConnect(RPostgres::Postgres(), dbname="indicators")
dbWriteTable(conn=con, name="indicators", value=as.data.frame(indicators),
             overwrite=TRUE)
dbWriteTable(conn=con, name="metadata", value=as.data.frame(metadata),
             overwrite=TRUE)
dbDisconnect(con)
