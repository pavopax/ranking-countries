require(shiny)
require(rCharts)


server<-function(input,output){
  output$myChart<-renderChart({
      p1<-rPlot(input$x,input$y, data=usn,
                type="point",color=input$color,facet=input$facet)
    p1$addParams(dom="myChart")
    return(p1)
  })
}

ui<-pageWithSidebar(
  headerPanel("Motor Trend Cars data with rCharts"),
  sidebarPanel(
    selectInput(inputId="y",
                label="Y Variable",
                choices=names(mtcars),
                ),
    selectInput(inputId="x",
                label="X Variable",
                choices=names(mtcars),
    ),
    selectInput(inputId="color",
                label="Color by Variable",
                choices=names(mtcars[,c(2,8,9,10,11)]),
    ),
    selectInput(inputId="facet",
                label="Facet by Variable",
                choices=names(mtcars[,c(2,8,9,10,11)]),
    )    
    ),
  mainPanel(
    showOutput("myChart","polycharts")
    )
  )

shinyApp(ui=ui,server=server)
