library(gdata)
source("header.R")                      #source functions and load packages
source("R/functions.R")

## df_data0 <- read.xls("../data/GCI_Dataset_2006-07-2014-15.xlsx",
##                      sheet=2, na.strings="", header=TRUE, skip=3,
##                      stringsAsFactors=FALSE) %>% tbl_df

## df_metadata0 <- read.csv("../data/weforum/Metadata-Table 1.csv",
##                          na.strings="", header=TRUE,
##                          stringsAsFactors=FALSE) %>% tbl_df

## df_entities0 <- read.xls("../data/GCI_Dataset_2006-07-2014-15.xlsx",
##                          sheet=4, na.strings="", header=TRUE, skip=2,
##                          stringsAsFactors=FALSE) %>% tbl_df

## rows <- dim(df_data)[1]
## df_data <- df_data[-rows,]

## saveRDS(df_data0, "../cache/df_data.rds")
## saveRDS(df_metadata0, "../cache/df_metadata.rds")
## saveRDS(df_entities0, "../cache/df_entities.rds")

df_data <- readRDS("../cache/df_data.rds") %>% tbl_df
df_metadata <- readRDS("../cache/df_metadata.rds") %>% tbl_df
df_entities <- readRDS("../cache/df_entities.rds") %>% tbl_df
