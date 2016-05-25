library(DBI)
library(tibble)                         # for frame_data()
source("helpers/header.R")
source("helpers/functions.R")

usn60 <- readRDS("../cache/usn60.rds")

wb_data <- readRDS("../cache/wb_data.rds")
wb_metadata <- readRDS("../cache/wb_metadata.rds")
wb_entities <- readRDS("../cache/wb_entities.rds")

wef_data <- readRDS("../cache/wef_data.rds")
wef_metadata <- readRDS("../cache/wef_metadata.rds")
wef_entities <- readRDS("../cache/wef_entities.rds")

wingia_data <- readRDS("../cache/wingia_data.rds")
wingia_metadata <- readRDS("../cache/wingia_metadata.rds")

## ============================================================================
## DATA SUMMARIES
## ============================================================================
print("dim")
wb_data %>% dim
wef_data %>% dim
wingia_data %>% dim

print("Indicators")
wb_data$indicator %>% lengths
wef_data$indicator %>% lengths
wingia_data$indicator %>% lengths

print("Countries")
wb_data$country  %>% lengths
wef_data$country %>% lengths
wingia_data$country %>% lengths


## ============================================================================
## STANDARADIZE AND MERGE THE 3 DATASETS (WB + WEF + WINGIA)
## ============================================================================
indicators_full <- bind_rows(
    wb_data %>% select(country, indicator, value, zscore, subset),
    wef_data,
    wingia_data) %>%
    arrange(country, indicator)

indicators_full$subset[is.na(indicators_full$subset)] <- 0

indicators_full$country %<>%
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


## ============================================================================
## METADATA
## ============================================================================
wingia_metadata$source <- "WIN_Gallup"
wef_metadata$source <- "WEF"
wb_metadata$source <- "WB"

## to match label_short in WB
wef_metadata$label_short <- gsub("( \\(.+\\))", "", wef_metadata$label) %>%
    gsub("(,.+)", "", .) %>% 
    gsub("\\*", "", .) 

## the 12 GCI "pillars" form my subset
## replace "nth pillar:" with "Competitiveness:"
## using regex capturing group
wef_metadata$label_short %<>%
    gsub(".+pillar: (.*)", "Competitiveness, \\1", .)


## SELECT MY COLUMNS
wef_metadata %<>% select(indicator, label_short, source)
wb_metadata %<>%  select(indicator, label_short, source)
wingia_metadata %<>% select(indicator, label_short, source)

metadata_full <- bind_rows(wef_metadata, wb_metadata, wingia_metadata) %>%
    arrange(source, indicator)
metadata_full$label_short %<>% substr(., 1, 60)

## TODO
## make sure all indicators are %in% metadata and indicators tables and vv

## TODO: standardize the entities
## c() the entities with my indicator$countries,
## and then apply strategy from indicator$countries

## ============================================================================
## FINALIZE
## ============================================================================
indicators <- indicators_full %>% filter(subset>0)

metadata <- metadata_full %>%
    filter(indicator %in% (indicators$indicator %>% unique))
                                  

## TODO:
## x <- indicators_full$indicator %>% unique
## z <- x[!(x %in% metadata_full$indicator)]


## CHECKS
print("full:")
indicators_full$indicator %>% lengths
metadata_full$indicator %>% lengths

print("subset:")
indicators$indicator %>% lengths
metadata$indicator %>% lengths

## ============================================================================
## SAVE TO DATABASE (and /cache)
## ============================================================================
con <- dbConnect(RPostgres::Postgres(), dbname="indicators")
dbWriteTable(conn=con, name="indicators", value=as.data.frame(indicators), overwrite=TRUE)
dbWriteTable(conn=con, name="metadata", value=as.data.frame(metadata), overwrite=TRUE)
dbWriteTable(conn=con, name="indicators_full", value=as.data.frame(indicators_full), overwrite=TRUE)
dbWriteTable(conn=con, name="metadata_full", value=as.data.frame(metadata_full), overwrite=TRUE)
dbDisconnect(con)

write_my_csv("indicators")
write_my_csv("indicators_full")
write_my_csv("metadata")
write_my_csv("metadata_full")
