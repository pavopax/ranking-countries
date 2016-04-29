library(gdata)
source("header.R")
source("functions.R")

print("MAKE WORLD ECONOMIC FORUM DATA...")
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
rows <- dim(df_data0)[1]
df_data <- df_data0[-rows,]

df_data %<>% filter(Attribute == "Value")

df_data1 <- df_data %>% select(Placement, GLOBAL.ID, Series.unindented)
df_data2 <- df_data %>% select(Albania:Zimbabwe) %>%
    mutate_each(funs(as.numeric))

df_data <- bind_cols(df_data1, df_data2)



print("OUTPUT TO /cache...")
saveRDS(df_data, "../cache/df_data.rds")
saveRDS(df_metadata0, "../cache/df_metadata.rds")
saveRDS(df_entities0, "../cache/df_entities.rds")
print("DONE")
