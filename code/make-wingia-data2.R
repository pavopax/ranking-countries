source("header.R") 
source("functions.R")

print("CONTINUE MAKE WINGIA DATA...")
df0 <- read.csv("../cache/wingia_data_wide.csv", row.names=1,
                stringsAsFactors=FALSE) %>% tbl_df

df <- df0 %>%
    filter(country != "Global Average") %>%
    gather(indicator, value, 2:4) %>%
    group_by(indicator) %>% 
    mutate(zscore=scale(value, center=TRUE, scale=TRUE)[,]) %>%
    ungroup

df$indicator %<>% gsub("net_", "", .)

saveRDS(df, "../cache/wingia_data.rds")

## simple average is not == "Global Average"...
df0 %>% filter(country == "Global Average")

df %>% group_by(indicator) %>%
    summarise(mu=mean(value, na.rm = TRUE) %>% round(2))

