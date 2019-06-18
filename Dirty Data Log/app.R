library(shiny)

ui <- fluidPage(
 navbarPage(title = "Guide to Dirty Data",
            tabPanel("Metabolism", 
              h1("Metabolism"),
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
                   h1("Examples")
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

  
}

shinyApp(ui = ui, server = server)
