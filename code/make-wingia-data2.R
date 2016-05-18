source("header.R") 
source("functions.R")

print("CONTINUE MAKE WINGIA DATA...")
df0 <- read.csv("../cache/wingia_wide.csv", row.names=1) %>% tbl_df


