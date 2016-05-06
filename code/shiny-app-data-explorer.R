library(RPostgreSQL)
source("header.R")
library(shiny)
library(rCharts)

con <- dbConnect(RPostgres::Postgres(), dbname="indicators")
indicators <- dbGetQuery(con, "SELECT * from indicators") %>% tbl_df
metadata <- dbGetQuery(con, "SELECT * from metadata") %>% tbl_df
dbDisconnect(con)

df <- indicators %>% select(-value) %>%
    left_join(.,
              metadata %>% select(indicator, label_short, source),
              by="indicator") %>%
    filter(!is.na(label_short)) %>%
    select(-indicator) %>%
    spread(label_short, zscore) %>%
    select(-source, -country)


colors <- "Corporateethics"
features <- names(df)

## shiny names can't have non-alpha characters
names(df) %<>% gsub("[[:punct:]]", " ", .) %>%
    gsub("\\s{2,}", "", .) %>%
    gsub("\\d+", "", .) %>%
    gsub(" ", "_", .)

server <- function(input,output){
    output$myChart<-renderChart2({
        p1<-rPlot(input$x,input$y, data=df,type="point",color=input$color)
        return(p1)
    })
}

ui <- pageWithSidebar(
    headerPanel("Data Explorer"),
    sidebarPanel(
        selectInput(inputId="y",
                    label="Y Variable",
                    choices=names(df),
                    ),
        selectInput(inputId="x",
                    label="X Variable",
                    choices=names(df),
                    ),
    selectInput(inputId="color",
                label="Color by Variable",
                choices=names(df)[3])
    ),
    mainPanel(
        showOutput("myChart","polycharts")
    )
)

shinyApp(ui=ui,server=server)



