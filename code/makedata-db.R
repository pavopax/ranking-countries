library(DBI)
library(tibble)                         # for frame_data()
source("header.R")
source("functions.R")


usn60 <- readRDS("../cache/usn60.rds")
wb_data <- readRDS("../cache/wb_data.rds")
wb_metadata <- readRDS("../cache/wb_metadata.rds")
wb_entities <- readRDS("../cache/wb_entities.rds")
wef_data <- readRDS("../cache/wef_data.rds")
wef_metadata <- readRDS("../cache/wef_metadata.rds")
wef_entities <- readRDS("../cache/wef_entities.rds")
wingia_data <- readRDS("../cache/wingia_data.rds")

## ============================================================================
## DATA SUMMARIES
## ============================================================================
wb_data %>% dim
wef_data %>% dim
wingia_data %>% dim

wb_data$indicator %>% unique %>% length
wef_data$indicator %>% unique %>% length

wb_data$country %>% unique %>% length
wef_data$country %>% unique %>% length
wingia_data$country %>% unique %>% length

## ============================================================================
## STANDARADIZE AND MERGE THE 2 DATASETS (WB + WEF)
## ============================================================================
indicators <- bind_rows(
    wef_data,
    wb_data %>% select(country, indicator, value, zscore),
    wingia_data
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
    gsub("Brunei Darussalam", "Brunei", .) %>%
    gsub("Bosnia And", "Bosnia and", .) %>%
    gsub("Congo, Democratic.*", "Congo DR", .) %>%
    gsub("Dem. Rep. Congo", "Congo DR", .)


## MAKE METADATA
wingia_metadata <- frame_data(
    ~indicator, ~label_short, 
    "net_hope", "Net hope", 
    "net_happiness", "Net happiness",
    "net_econ_optimism", "Net economic optimism"
)

wingia_metadata$source <- "WIN/Gallup"
wef_metadata$source <- "WEF"
wb_metadata$source <- "WB"


## to match label_short in WB
wef_metadata$label_short <- gsub("( \\(.+\\))", "", wef_metadata$label) %>%
    gsub("(,.+)", "", .) %>% 
    gsub("\\*", "", .) 


metadata <- bind_rows(wef_metadata, wb_metadata) %>%
    select(source, indicator, label_short, label, description) %>%
    arrange(source, indicator)
metadata$label_short %<>% substr(., 1, 60)

## TODO: standardize the entities
## c() the entities with my indicator$countries,
## and then apply strategy from indicator$countries


## ============================================================================
## SAVE TO DATABASE (and /cache)
## ============================================================================
con <- dbConnect(RPostgres::Postgres(), dbname="indicators")
dbWriteTable(conn=con, name="indicators", value=as.data.frame(indicators),
             overwrite=TRUE)
dbWriteTable(conn=con, name="metadata", value=as.data.frame(metadata),
             overwrite=TRUE)
dbDisconnect(con)

saveRDS(indicators, "../cache/indicators.rds")
saveRDS(metadata, "../cache/metadata.rds")
