library(gdata)
source("header.R")
source("functions.R")

print("MAKE WORLD ECONOMIC FORUM DATA...")
## takes forever... should export to csv from excel...
df_data0 <- read.xls("../data/GCI_Dataset_2006-07-2014-15.xlsx",
                     sheet=2, na.strings="", header=TRUE, skip=3,
                     stringsAsFactors=FALSE) %>% tbl_df

df_metadata0 <- read.csv("../data/weforum/Metadata-Table 1.csv",
                         na.strings="", header=TRUE,
                         stringsAsFactors=FALSE) %>% tbl_df

df_entities0 <- read.xls("../data/GCI_Dataset_2006-07-2014-15.xlsx",
                         sheet=4, na.strings="", header=TRUE, skip=2,
                         stringsAsFactors=FALSE) %>% tbl_df


print("EDIT DF_DATA...")
## most recent 2015-2016 is not in dataset...
df_data <- df_data0 %>% filter(Edition=="2014-2015")
df_data %<>% filter(Attribute=="Value")
# max(df_data$Placement)==dim(df_data)[1]
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

print("EDIT OTHERS...")
df_metadata <- df_metadata0 %>%
    select(GLOBAL.ID, Series.unindented, Description) %>%
    rename(indicator=GLOBAL.ID, label=Series.unindented)
names(df_metadata) %<>% tolower

df_entities <- df_entities0 %>%
    rename(region.imf = Region..IMF..April.2014.,
           income.group = Income.group..World.Bank..July.2014.)
names(df_entities) %<>% tolower


print("SAVE TO /cache...")
saveRDS(df_data, "../cache/wef_data.rds")
saveRDS(df_metadata, "../cache/wef_metadata.rds")
saveRDS(df_entities, "../cache/wef_entities.rds")
print("DONE")
