source("helpers/header.R")
source("helpers/functions.R")
library(readxl)

df_data0 <- read_excel("../data/GCI_Dataset_2006-07-2014-15.xlsx",
                       sheet=2, na="", skip=3)
df_metadata0 <- read_excel("../data/GCI_Dataset_2006-07-2014-15.xlsx",
                           sheet=3, na="", skip=2)
df_entities0 <- read_excel("../data/GCI_Dataset_2006-07-2014-15.xlsx",
                           sheet=4, na="", skip=2)

names(df_data0) %<>% gsub(" ", ".", .) %>%
    iconv(., "latin1", "ASCII", sub="")
names(df_metadata0) %<>% gsub(" ", ".", .) %>% tolower
names(df_entities0) %<>% gsub(" ", ".", .) %>%
    gsub("\\(|,|)", "", .) %>% tolower


## most recent 2015-2016 is not in dataset...
df_data <- df_data0 %>% filter(Edition=="2014-2015")
df_data %<>% filter(Attribute=="Value")
#max(df_data$Placement)==dim(df_data)[1]
df_data1 <- df_data %>% select(Attribute, GLOBAL.ID, Series.unindented)
df_data2 <- df_data %>% select(Albania:Zimbabwe) %>%
    mutate_each(funs(as.numeric))
df_data <- bind_cols(df_data1, df_data2)

## from wide to long
df_data %<>% gather(., country, value, Albania:Zimbabwe) %>%
    rename(label=Series.unindented, indicator=GLOBAL.ID) %>% 
    select(country, indicator, value)
df_data$country %<>% as.character

## add z-score
df_data %<>%
    group_by(indicator) %>%
    mutate(zscore=scale(value, center = TRUE, scale=TRUE)[,]) %>%
    ungroup()


## METADATA, ENTITIES
df_metadata <- df_metadata0 %>%
    select(global.id, series.unindented, description) %>%
    rename(indicator=global.id, label=series.unindented)


df_entities <- df_entities0 %>%
    rename(region.imf = region.imf.april.2014,
           income.group = income.group.world.bank.july.2014)


## add my subset
pillars <- df_metadata %>% filter(grepl("pillar", label)) %>% .$indicator
df_data %<>% mutate(subset=ifelse(indicator %in% pillars, 1, 0))

saveRDS(df_data, "../cache/wef_data.rds")
saveRDS(df_metadata, "../cache/wef_metadata.rds")
saveRDS(df_entities, "../cache/wef_entities.rds")

