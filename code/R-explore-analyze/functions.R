## DOCUMENT THESE WITH TAGS

##' .. content for \description{} (no empty lines) ..
##' Get n() of indicators
##' .. content for \details{} ..
##' @title 
##' @param data data frame
##' @return data frame in wide format 
##' @author Pawel
get_indicator_counts <- function(data){
    data %>% group_by(Year, Series.Code) %>%
        na.omit() %>% summarise(n=n()) %>%
        arrange(Year, desc(n))
}
