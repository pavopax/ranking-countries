##' .. content for \description{} (no empty lines) ..
##' Get n() of indicators
##' .. content for \details{} ..
##' @title 
##' @param data data frame
##' @return data frame in wide format 
##' @author Paul
get_indicator_counts <- function(data){
    data %>% group_by(year, indicator) %>%
        na.omit() %>% summarise(n=n()) %>%
        arrange(year, desc(n))
}

##' .. content for \description{} (no empty lines) ..
##' get latest available indicator. no indicator if NA
##' .. content for \details{} ..
##' @title 
##' @param data 
##' @return 
##' @author Paul
get_latest_available <- function(data){
    data %>% na.omit() %>% group_by(country, indicator) %>% 
        arrange(desc(year)) %>% slice(1) %>% ungroup()
}

##' .. content for \description{} (no empty lines) ..
##' write CSV to path. pass object name
##' .. content for \details{} ..
##' @title 
##' @param path path as string
##' @param object_name your object as string
##' @return csv with same name as object name, written to path
##' @author Paul
write_my_csv <- function(object_name, out_name, path="../cache/"){
    if(missing(out_name)) {out_name <- object_name}
    write.csv(get(object_name), file=paste0(path, object_name, ".csv"))
}



##' .. content for \description{} (no empty lines) ..
##' return missclassification rate
##' .. content for \details{} ..
##' @title 
##' @param table : table() of Y's: predictions x observations 
##' @return value [0,1]
##' @author Paul
missclass_rate <- function(table){
    return (sum(table)-tr(table))/sum(table)
}

##' .. content for \description{} (no empty lines) ..
##' in vector, convert NA to n (or zero, by default)
##' .. content for \details{} ..
##' @title 
##' @param x 
##' @return 
##' @author Paul
na.zero <- function (x, n=0) {
    x[is.na(x)] <- n
    return(x)
}



##' .. content for \description{} (no empty lines) ..
##' .. content for \details{} ..
##' @title 
##' @param x a vector
##' @return length, unique length
##' @author Paul
lengths <- function(x) {
    return (c(x %>% length,
              x %>% unique %>% length))
}
