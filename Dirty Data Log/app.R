library(shiny)

bigDataSet <- read.csv("NC_NHC_DO_mgL.csv")

ui <- fluidPage(
 navbarPage(title = "Guide to Dirty Data",
            tabPanel("Metabolism", 
              h1("Metabolism"),
              br(),
              p("Stream metabolism can be thought of as the exchange of energy in the forms of oxygen and carbon. 
                This exchange occurs within the stream scosystem between autotrophs and heterotrophs in addition to with the external ecosystem."),
              HTML('<center><img src="O and CO2 Exchange.jpg", width = 500, height = 300></center>'),
              br(),
              p("In 1956, Odum and his team developed a model that estimates metabolism as a function of oxygen concentration:"),
              withMathJax(
                helpText('$$\\frac{dO}{dt}=\\mathrm{GPP+ER}+K*\\mathrm{O}_\\mathrm{def}$$')
              ), 
              p("Odum Metabolism Model", align="center")
            ),
            tabPanel("Clean Data", 
               sidebarLayout(
                 sidebarPanel(
                   selectInput(inputId = "cleanVar",
                               label = "Select time interval:",
                               choices = c("Day", "Week", "Month", "Year")
                   )
                 ),
                 mainPanel(
                   h1("Examples"),
                   textOutput("selected_clean"),
                   plotOutput("plot_time")
                 )
               )      
            ),
            tabPanel("Dirty Data", 
              sidebarLayout(
                sidebarPanel(
                  selectInput(inputId = "dirtyVar",
                            label = "Select a variable:",
                            choices = c("rock", "pressure", "cars")
                  )
                ),
                mainPanel(
                  h1("Examples")
                )
              )
            )
 )

)

server <- function(input, output) {
  clean_type <- reactive({(input$cleanVar)})
  output$selected_clean <- renderText({ 
    paste("Below is an oxygen curve considered to be clean and complete for the time period of a", tolower(clean_type()), ":")
  })
  output$plot_time <- renderPlot({
    if(clean_type() == "Day"){
      clean <- read.csv("Day.csv")
      graph_type <- "Day of Dissolved Oxygen Data"
    }
    if(clean_type() == "Week"){
      clean <- read.csv("Week.csv")
      graph_type <- "Week of Dissolved Oxygen Data"
    }
    if(clean_type() == "Month"){
      clean <- read.csv("Month.csv")
      graph_type <- "Month of Dissolved Oxygen Data"
    }
    if(clean_type() == "Year"){
      clean <- read.csv("Month.csv")
      graph_type <- "Year of Dissolved Oxygen Data"
    }
    df <- data.frame(
      date = clean$dateTimeUTC,
      value = clean$value
    )
    plot(df$date, df$value,
         type='l',
         main = graph_type, 
         xlab ="Time Stamp", 
         ylab ="DO_mgL")
  })
  
}

shinyApp(ui = ui, server = server)
