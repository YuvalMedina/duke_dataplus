library(shiny)
library("lubridate")
library("ggplot2")
source("gap_detect.R")



dirty_dates <- vector(mode = "list", length = 3)
names(dirty_dates) <- c("Storm", "Outliers", "Gaps")
dirty_dates[[1]] <- c("2017-03-02 00:00:00", "2017-03-03 00:00:00")
dirty_dates[[2]] <- c("2017-03-02 00:00:00", "2017-03-03 00:00:00")
dirty_dates[[3]] <- c("2017-06-21 15:00:00", "2017-06-27 21:00:00")

dirty_DO_range <- vector(mode = "list", length = 3)
names(dirty_DO_range) <- c("Storm", "Outliers", "Gaps")
dirty_DO_range[[1]] <- c(7.5, 12.5)
dirty_DO_range[[2]] <- c(7.5, 12.5)
dirty_DO_range[[3]] <- c(6, 9)

dirty_disch_range <- vector(mode = "list", length = 3)
names(dirty_disch_range) <- c("Storm", "Outliers", "Gaps")
dirty_disch_range[[1]] <- c(0, 6)
dirty_disch_range[[2]] <- c(0,6)
dirty_disch_range[[3]] <- c(0,6)

ui <- fluidPage(
 navbarPage(title = "Guide to Dirty Data",
              tabPanel("Metabolism", 
                       fluidRow(
                         column(8, offset=2,
                                h1("Metabolism"),
                                br(),
                                h3("What is Metabolism"),
                                "Stream metabolism is the measure of energy exchanged within the 
                                stream ecosystem in the forms of oxygen and carbon. The two primary modes
                                of exchange are primary production by autotrophs in which oxygen is produced and
                                carbon is consumed, and respiration by heterotrophs in which oxygen is consumed
                                carbon is produced. As research in stream metabolism modeling expands, we can gain
                                a deeper understanding in how different external disturbances and environments
                                can affect the productivity of the stream ecosystem.",
                                br(),
                                br(),
                                br(),
                                HTML('<center><img src="O and CO2 Exchange.jpg", width = 500, height = 300></center>'),
                                br(),
                                h3("Modeling Metabolism"),
                                "In 1956, Odum and his team developed a model that estimates metabolism as a function of oxygen concentration:",
                                withMathJax(
                                  helpText('$$\\frac{dO}{dt}=\\mathrm{GPP+ER}+K*\\mathrm{O}_\\mathrm{def}$$')
                                ), 
                                "This model uses the change in oxygen over every time interval to calculate the 
                                oxygen produced through primary production and consumed through respiration to calculate
                                the average metabolism for each day. Therefore, to accurately model metabolism, the 
                                oxygen curve must be a complete data set with few gaps. There must also be a high variance
                                in oxygen concentration such as in the oxygen curve below showing data for one day.",
                                HTML('<center><img src="DO curve.png", width = 400, height = 400></center>')
                                
                            )
                                
                       )
            ),
            tabPanel("Clean Data", 
                     fluidRow(
                       column(10, offset=0,
                              sidebarLayout(
                                sidebarPanel(
                                  h3("Clean Data"),
                                  "Here are some time series plots over varying time intervals
                                  that portray clean and complete oxygen curves ideal for
                                  accurately modeling stream metabolism.",
                                  br(),
                                  br(),
                                  selectInput(inputId = "cleanVar",
                                              label = "Select time interval:",
                                              choices = c("Day", "Week", "Month", "Year")
                                  )
                                ),
                                mainPanel(
                                  h1("Ideal Data for Modeling Metabolism"),
                                  textOutput("selected_clean"),
                                  plotOutput("plot_time")
                                )
                              )
                          )
                     )
                     
            ),
            tabPanel("Dirty Data", 
              sidebarLayout(
                sidebarPanel(
                 # selectInput(inputId = "dirtyVar",
                  #          label = "Select a file",
                   #         choices = list.files(pattern='.csv')
                #  ),
                 # sliderInput(inputId = "time_int",
                  #            label = "Select time interval of data collection (minutes)",
                   #           min = 0, max = 60, value = 30, step = 5),
                  selectInput(inputId = "dirtyType",
                              label = "Select a type of dirty data",
                              choices = c("Storm", "Outliers", "Gaps"))
                  
                  #plotOutput("plot_time")
                ),
                mainPanel(
                  h1("Examples and Explanations of Dirty Data"),
                  br(),
                  textOutput("dirty_type"),
                  tags$head(tags$style("#dirty_type{color: black;
                                 font-size: 24px;
                                 font-style: bold;
                                 }")
                  ),
                  br(),
                  uiOutput("dirty_img"),
                  textOutput("dirty_text"),
                  plotOutput("dirty_disch_plot"),
                  textOutput("dirty_info"),
                  plotOutput("dirty_DO_plot")
                  
                )
              )
            )
 )

)

server <- function(input, output) {
  clean_type <- reactive({(input$cleanVar)})
  dirty_file <- reactive({(input$dirtyVar)})
  time_gap <- reactive({(input$time_int)})
  dirty_choice <- reactive({(input$dirtyType)})
  
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
  
 # output$plot_time <- renderPlot({
 #   gaps = gap.finding(dirty_file(), time_gap())
#    head(gaps)
 #   my_dirty_dat <- read.csv((dirty_file()))
  #  my_dirty_df <- data.frame(
   #   date = my_dirty_dat$dateTimeUTC,
    #  value = my_dirty_dat$value
    #)
  #  for (i in range(gaps.length())){
   #   graph_dat <- my_dirty_df[gaps[i]-100:gaps[i]+100]
    #  plot(graph_dat$date, graph_dat$value)
  #  }
#  })
  
  output$dirty_type <- renderText({
    paste(dirty_choice(), "Data")
  })
  
  output$dirty_DO_plot <- renderPlot({
    choice <- dirty_choice()
    DO <- read.csv(paste0(choice, "_DO.csv"))
    
    df_DO <- data.frame(
      date = as.POSIXct(DO$dateTimeUTC, tz='', 
                        format = "%Y-%m-%d %H:%M:%S"),
      values = DO$value
    )
    print(dirty_dates$choice[1])
    print(class(dirty_dates$choice[1]))
    message(dirty_dates$choice[1])
    ggplot() +
      geom_point(df_DO, mapping=aes(x=date, y=values))+
      geom_rect(data = data.frame(xmin = as.POSIXct(c(dirty_dates[[choice]][1])),
                                  xmax = as.POSIXct(c(dirty_dates[[choice]][2])),
                                  ymin = dirty_DO_range[[choice]][1],
                                  ymax = dirty_DO_range[[choice]][2]),
                aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
                fill = "red", alpha = 0.2) 
  })
  
  output$dirty_info <- renderText({
    
    
    
    
    
    
  })
  
  output$dirty_disch_plot <- renderPlot({
    choice <- dirty_choice()
    disch <- read.csv(paste0(choice, "_discharge.csv"))
    df_disch <- data.frame(
      date = as.POSIXct(disch$dateTimeUTC, tz='', 
                        format = "%Y-%m-%d %H:%M:%S"),
      values = disch$value
    )
    ggplot() +
      geom_point(df_disch, mapping=aes(x=date, y=values))+
      geom_rect(data = data.frame(xmin = as.POSIXct(c(dirty_dates[[choice]][1])),
                                  xmax = as.POSIXct(c(dirty_dates[[choice]][2])),
                                  ymin = dirty_disch_range[[choice]][1],
                                  ymax = dirty_disch_range[[choice]][2]),
                aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
                fill = "red", alpha = 0.2) 
    
  })
  
  #output$dirty_img<-renderUI({
  #  if(dirty_choice()=='Storm'){
  #    img(src='Storm.png', height = '300px', align = 'center')
  #  }
  #    
#  })
  
  output$dirty_text<-renderText({
    if(dirty_choice() == 'Storm'){
      paste("Storms can be identified with peaks in discharge plots as shown on May 2 with yellow points. When looking at the ")
    }
      
  })
}

shinyApp(ui = ui, server = server)
