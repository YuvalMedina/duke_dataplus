library(shiny)
library(shinydashboard)
dashboardPage(
  dashboardHeader(disable = T),
  dashboardSidebar(disable = T),
  dashboardBody()
)

library("lubridate")
library("ggplot2")
source("gap_detect.R")


dirty_dates <- vector(mode = "list", length = 4)
names(dirty_dates) <- c("Storm", "Outliers", "Gaps", "Sensor Error")
dirty_dates[[1]] <- c("2017-03-02 00:00:00", "2017-03-03 00:00:00")
dirty_dates[[2]] <- c("2017-03-02 00:00:00", "2017-03-03 00:00:00")
dirty_dates[[3]] <- c("2017-06-21 15:00:00", "2017-06-27 21:00:00")
dirty_dates[[4]] <- c("2017-04-18 05:30:00", "2017-04-24 18:00:00")

dirty_DO_range <- vector(mode = "list", length = 4)
names(dirty_DO_range) <- c("Storm", "Outliers", "Gaps", "Sensor Error")
dirty_DO_range[[1]] <- c(7.5, 12.5)
dirty_DO_range[[2]] <- c(7.5, 12.5)
dirty_DO_range[[3]] <- c(6, 9)
dirty_DO_range[[4]] <- c(1, 10)

dirty_disch_range <- vector(mode = "list", length = 4)
names(dirty_disch_range) <- c("Storm", "Outliers", "Gaps", "Sensor Error")
dirty_disch_range[[1]] <- c(0, 6)
dirty_disch_range[[2]] <- c(0,6)
dirty_disch_range[[3]] <- c(0,6)
dirty_disch_range[[4]] <- c(0,140)

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
                                HTML('<center><img src="DO curve.png", width = 400, height = 400></center>'),
                                tabBox(width=12,id="tabBox_next_previous",
                                       tabPanel("Tab1",p("This is tab 1")),
                                       tabPanel("Tab2",p("This is tab 2")),
                                       tabPanel("Tab3",p("This is tab 3")),
                                       tabPanel("Tab4",p("This is tab 4")),
                                       tags$script("
                                          $('body').mouseover(function() {
                                          list_tabs=[];
                                          $('#tabBox_next_previous li a').each(function(){
                                          list_tabs.push($(this).html())
                                          });
                                          Shiny.onInputChange('List_of_tab', list_tabs);})
                                          "
                                       )
                                ),
                                uiOutput("Next_Previous"),
                                
                                  #tabPanel("Instructions",
                                 #     
                                    
                                  #tabPanel("Raw Data: Oxygen Curve"),
                                 # tabPanel("Next Step"),
                                 # tabPanel("Final Step")
                                #),
                                br(),
                                br(),
                                br()
                                
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
                     fluidRow(
                       column(10, offset=0,
                              sidebarLayout(
                                sidebarPanel(
                                  h3("Dirty Data"),
                                  'Here are visualization of some common types of dirty data within
                                  oxygen curves and the corresponding discharge data seen by stream 
                                  metabolism researchers. Within each time series, the data highlighted in red
                                  is considered there the data has gone "bad".',
                                  br(),
                                  br(),
                                  selectInput(inputId = "dirtyType",
                                              label = "Select a type of dirty data",
                                              choices = c("Storm", "Outliers", "Gaps", "Sensor Error"))
                
                                ),
                                mainPanel(
                                  h1("Examples and Explanations of Dirty Data"),
                                  br(),
                                  textOutput("dirty_type"),
                                  tags$head(tags$style("#dirty_type{color: black;
                                     font-size: 24px;
                                     font-style: bold;
                                     }")),
                                  br(),
                                  textOutput("dirty_text"),
                                  br(),
                                  plotOutput("dirty_DO_plot"),
                                  plotOutput("dirty_disch_plot")
                                  
                                  
                                  
                                )
                              )
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
  Previous_Button=tags$div(actionButton("Prev_Tab","Previous"))
  Next_Button=div(actionButton("Next_Tab","Next"))
  
  output$Next_Previous=renderUI({
    tab_list=input$List_of_tab[-length(input$List_of_tab)]
    nb_tab=length(tab_list)
    if (which(tab_list==input$tabBox_next_previous)==nb_tab)
      column(1,offset=1,Previous_Button)
    else if (which(tab_list==input$tabBox_next_previous)==1)
      column(1,offset = 10,Next_Button)
    else
      div(column(1,offset=1,Previous_Button),column(1,offset=8,Next_Button))
    
  })
  observeEvent(input$Prev_Tab,
               {
                 tab_list=input$List_of_tab
                 current_tab=which(tab_list==input$tabBox_next_previous)
                 updateTabsetPanel(session,"tabBox_next_previous",selected=tab_list[current_tab-1])
               }
  )
  observeEvent(input$Next_Tab,
               {
                 tab_list=input$List_of_tab
                 current_tab=which(tab_list==input$tabBox_next_previous)
                 updateTabsetPanel(session,"tabBox_next_previous",selected=tab_list[current_tab+1])
               }
  )
  
  
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
    ggplot() +
      ggtitle("DO Data from", choice)+
      xlab("Date")+
      ylab("DO (mgL)")+
      geom_point(df_DO, mapping=aes(x=date, y=values))+
      geom_rect(data = data.frame(xmin = as.POSIXct(c(dirty_dates[[choice]][1])),
                                  xmax = as.POSIXct(c(dirty_dates[[choice]][2])),
                                  ymin = dirty_DO_range[[choice]][1],
                                  ymax = dirty_DO_range[[choice]][2]),
                aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
                fill = "red", alpha = 0.2)+
      theme(
        plot.title = element_text( size=17, face="bold"),
        axis.title.x = element_text(size=14, face="bold"),
        axis.title.y = element_text(size=14, face="bold")
      )
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
      ggtitle("Discharge Data from", choice)+
      xlab("Date")+
      ylab("Discharge (m3s)")+
      geom_point(df_disch, mapping=aes(x=date, y=values))+
      geom_rect(data = data.frame(xmin = as.POSIXct(c(dirty_dates[[choice]][1])),
                                  xmax = as.POSIXct(c(dirty_dates[[choice]][2])),
                                  ymin = dirty_disch_range[[choice]][1],
                                  ymax = dirty_disch_range[[choice]][2]),
                aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
                fill = "red", alpha = 0.2) +
      theme(
        plot.title = element_text( size=17, face="bold"),
        axis.title.x = element_text(size=14, face="bold"),
        axis.title.y = element_text(size=14, face="bold"))
    
  })
  
  output$dirty_text<-renderText({
    if(dirty_choice() == "Storm"){
      paste("Storms can be identified with peaks in discharge plots as shown on March 2 in the red area. When looking at the 
            correlating disolved oxygen curve, the amplitude of the curve can be observed to have
            decreased. However, the curve itself maintained the ideal clean and complete shape and can
            be used to model metabolism.")
    }
    if(dirty_choice() == 'Gaps'){
      paste("Sensors are removed from the stream in event of a storm to prevent the sensor from 
            being lost in fast-flowing waters or for the general need to remove them for technical
            reasons. The sensors can be removed for just hours or for multiple days, resulting in gaps
            in the data such as in the dissolved oxygen graph below. With this missing data, researchers are unable to accurately model metabolism
            for each day.")
    }
    if(dirty_choice() == 'Outliers'){
      paste("Storms ")
    }
    if(dirty_choice() == 'Sensor Error'){
      paste("As a broader type of bad data, sensor error encompasses a wide variety of situations in which
            the data collected cannot be used to accurately calculate metabolism. These situations can 
            range from the sensor being buried under sand or microbials, to there being a technical 
            malfunction within the sensor. When visualizing such data, the data often appears random and
            strays from the expected daily patterns as can be seen in the oxygen curve below.")
    }
      
  })
}

shinyApp(ui = ui, server = server)
