source("header.R") 
source("functions.R")

## ============================================================================
## make datasets
## ============================================================================
usn0 <- read.csv("../cache/latest_usn.csv", stringsAsFactors=FALSE,
                row.names=1) %>% tbl_df
codes <- read.csv("../cache/codes.csv", stringsAsFactors=FALSE,
                  row.names=1) %>% tbl_df
attrs <- read.csv("../cache/attrs.csv", stringsAsFactors=FALSE,
                  row.names=1) %>% tbl_df

usn_feats <- attrs %>% select(indicator, usn_feat) %>% na.omit() %>%
    filter(usn_feat==1) %>% .$indicator


usn.wide <- usn0 %>% left_join(., codes, by="indicator") %>%
    select(country, indicator, label_short, zscore) %>%
    filter(indicator %in% usn_feats) %>% select(-indicator) %>%
    spread(label_short, zscore) %>%
    mutate_each(funs(na.zero(.)))

## ============================================================================
## make graphics
## ============================================================================

## amazing
## https://cran.r-project.org/web/packages/corrplot/vignettes/corrplot-intro.html
library(corrplot)                       

dat <- usn.wide
M <-  cor(dat[,-1])

png("../output/3-corrs.png", width=800, height=800)
corrplot(M, method="ellipse", order="FPC")
dev.off()
