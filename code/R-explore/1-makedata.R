source("header.R")

dfinput0 <- read.csv("../../data/week2indicators/10a9a8fd-ffd8-4cff-b371-b52e1b415949_Data.csv",
                     stringsAsFactors=FALSE) %>% tbl_df

df_meta0 <- read.csv("../../data/country-metadata.csv",
                     stringsAsFactors=FALSE) %>% tbl_df

## TODO: get from scrape output
usnews0 <- c("Algeria", "Argentina", "Australia", "Austria",
            "Azerbaijan", "Bolivia", "Brazil", "Bulgaria", "Canada",
            "Chile", "China", "Colombia", "Costa Rica",
            "Czech Republic", "Denmark", "Dominican Republic",
            "Egypt", "France", "Germany", "Greece", "Guatemala",
            "Hungary", "India", "Indonesia", "Iran", "Ireland",
            "Israel", "Italy", "Japan", "Jordan", "Kazakhstan",
            "Luxembourg", "Malaysia", "Mexico", "Morocco",
            "Netherlands", "New Zealand", "Nigeria", "Pakistan",
            "Panama", "Peru", "Philippines", "Portugal", "Romania",
            "Russia", "Saudi Arabia", "Singapore", "South Africa",
            "South Korea", "Spain", "Sri Lanka", "Sweden",
            "Thailand", "Tunisia", "Turkey", "Ukraine",
            "United Kingdom", "United States", "Uruguay", "Vietnam")

## standardize names to MATCH world bank names
usnews <- gsub("South Korea", "Korea, Rep.", usnews0) %>%
    gsub("Egypt", "Egypt, Arab Rep.", .) %>%
    gsub("Russia", "Russian Federation", .) %>% 
    gsub("Iran", "Iran, Islamic Rep.", .)


## munge country metadata
df_meta <- df_meta0 %>% select(X...Country.Name, Region) %>%
    rename(Country.Name=X...Country.Name)

dfff <- left_join(dfinput0, df_meta, by="Country.Name") %>%
    filter(Series.Code != "") %>%
    rename(Country=Country.Name)

paste("rename variables")
n0 <- names(dfff)
names(dfff) <- gsub("X...", "", names(dfff), fixed=TRUE) %>%
    gsub("..", "_", ., fixed=TRUE) %>% gsub("_.*", "", .)
cbind(before=n0, after=names(dfff))

tonum <- function(x) as.numeric(gsub("..", NA, x, fixed=TRUE))

split1 <- dfff %>% select(starts_with("X2")); split1
split1 %<>% mutate_each(funs(tonum(.)))
split2 <- dfff %>% select(Series.Name, Series.Code, Country, Country.Code,
                          Region)

df0 <- as.data.frame(cbind(split2, split1)) %>% tbl_df

## ============================================================================
## explor
## ============================================================================

indx <- c("NY.GDP.MKTP.CD", "NY.GDP.PCAP.CD", "SP.POP.TOTL", "AG.LND.TOTL.K2", "ST.INT.ARVL", "ST.INT.RCPT.XP.ZS", "IQ.CPA.GNDR.XQ", "IQ.CPA.PROP.XQ", "IT.NET.BBND.P2", "SE.ADT.LITR.ZS", "TX.VAL.TECH.MF.ZS", "TX.VAL.TECH.CD", "IQ.CPA.TRAN.XQ", "SL.UEM.TOTL.ZS", "SI.POV.GINI", "SE.TER.ENRR", "SP.DYN.LE00.IN")

df <- df0 %>% filter(Series.Code %in% indx)
df %<>% gather(., "year", "value", X2000:X2012) %>%
    select(Country, Series.Code, year, value, Country.Code, Region, Series.Name)

## now, for each code, take average over all years
