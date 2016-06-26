source("helpers/header.R") 
source("helpers/functions.R")
library(tibble)                         #frame_data()

df0 <- read.csv("../cache/wingia_data_wide.csv", row.names=1,
                stringsAsFactors=FALSE) %>% tbl_df

df <- df0 %>%
    filter(country != "Global Average") %>%
    gather(indicator, value, 2:4) %>%
    group_by(indicator) %>% 
    mutate(zscore=scale(value, center=TRUE, scale=TRUE)[,]) %>%
    ungroup

df$indicator %<>% gsub("net_", "", .)
df$subset <- 3

wingia_metadata <- frame_data(
    ~indicator, ~label_short, 
    "hope", "Net hope",
    "happiness", "Net happiness",
    "econ_optimism", "Net economic optimism"
)


saveRDS(df, "../cache/wingia_data.rds")
saveRDS(wingia_metadata, "../cache/wingia_metadata.rds")

## simple average is not == "Global Average"...
df0 %>% filter(country == "Global Average")

df %>% group_by(indicator) %>%
    summarise(mu=mean(value, na.rm = TRUE) %>% round(2))
