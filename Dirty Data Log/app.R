library(shiny)
library(shinydashboard)
library(scales)
dashboardPage(
  dashboardHeader(disable = T),
  dashboardSidebar(disable = T),
  dashboardBody()
)

library("lubridate")
library("ggplot2")
source("gap_detect.R")

clean_dates <- vector(mode = "list", length = 3)
names(clean_dates) <- c("Day", "Week", "Month")
clean_dates[[1]] <- c("2017-03-07 00:00:00", "2017-03-08 00:00:00")
clean_dates[[2]] <- c("2017-03-07 00:00:00", "2017-03-14 00:00:00")
clean_dates[[3]] <- c("2017-03-07 00:00:00", "2017-04-07 00:00:00")

dirty_dates <- vector(mode = "list", length = 5)
names(dirty_dates) <- c("Storm", "Outliers", "Gaps", "Sensor Error", "Sensor Out of Water")
dirty_dates[[1]] <- c("2017-03-02 00:00:00", "2017-03-03 00:00:00")
dirty_dates[[2]] <- c("2017-05-30 13:00:00", "2017-05-30 14:30:00")
dirty_dates[[3]] <- c("2018-12-05 14:00:00", "2018-12-06 15:00:00")
dirty_dates[[4]] <- c("2017-04-18 05:30:00", "2017-04-24 18:00:00")
dirty_dates[[5]] <- c("2017-04-18 05:30:00", "2017-04-24 18:00:00")

dirty_DO_range <- vector(mode = "list", length = 5)
names(dirty_DO_range) <- c("Storm", "Outliers", "Gaps", "Sensor Error", "Sensor Out of Water" )
dirty_DO_range[[1]] <- c(7.5, 12.5)
dirty_DO_range[[2]] <- c(6, 9)
dirty_DO_range[[3]] <- c(7, 14)
dirty_DO_range[[4]] <- c(1, 10)
dirty_DO_range[[5]] <- c(1, 10)

dirty_loc <- vector(mode = "list", length = 5)
names(dirty_loc) <- c("Storm", "Outliers", "Gaps", "Sensor Error", "Sensor Out of Water")
dirty_loc[[1]] <- c("North Carolina" , "Eno")
dirty_loc[[2]] <- c("North Carolina", "Eno")
dirty_loc[[3]] <- c("Arizona", "Lower Verde")
dirty_loc[[4]] <- c("North Carolina", "Eno")
dirty_loc[[5]] <- c("North Carolina", "Eno")

dirty_disch_range <- vector(mode = "list", length = 5)
names(dirty_disch_range) <- c("Storm", "Outliers", "Gaps", "Sensor Error", "Sensor Out of Water")
dirty_disch_range[[1]] <- c(0, 6)
dirty_disch_range[[2]] <- c(0,6)
dirty_disch_range[[3]] <- c(2,4)
dirty_disch_range[[4]] <- c(0,140)
dirty_disch_range[[5]] <- c(0, 10)

dirty_info <- vector(mode = "list", length = 5)
names(dirty_info) <- c("Storm", "Outliers", "Gaps", "Sensor Error", "Sensor Out of Water")
dirty_info[[1]] <- c("Storms can be identified with peaks in discharge plots as shown on March 2 in the red area. When looking at the 
            correlating disolved oxygen curve, the amplitude of the curve can be observed to have
            decreased. However, the curve itself maintained the ideal clean and complete shape and can
            be used to model metabolism. In other cases, there is a sudden change in oxygen readings due to the
            fast-changing oxygen levels. In these situations, the data cannot
            be used to accurately model metabolism.")
dirty_info[[2]] <- c("Outliers can result from a variety of situations. In this plot, the sensor is reading
                     very negative values, which is indicitive of a temporary sensor malfunction or error. On the other
                     hand, outliers can be accurate sensor readings, but with interferences, whether there is a film of
                     aquatic organisms or sand surrounding the sensor.")
dirty_info[[3]] <- c("Sensors are removed from the stream in event of a storm to prevent the sensor from 
            being lost in fast-flowing waters or for the general need to remove them for technical
            reasons. The sensors can be removed for just hours or for multiple days, resulting in gaps
            in the data such as in the dissolved oxygen graph below. With this missing data, researchers are unable to accurately model metabolism
            for each day.")
dirty_info[[4]] <- c("As a broader type of bad data, sensor error encompasses a wide variety of situations in which
            the data collected cannot be used to accurately calculate metabolism. These situations can 
            range from the sensor being buried under sand or microbials, to there being a technical 
            malfunction within the sensor. When visualizing such data, the data often appears random and
            strays from the expected daily patterns as can be seen in the oxygen curve below.")
dirty_info[[5]] <- c("")

tabs <- vector(mode = "list", length = 4)
names(tabs) <- c("Introduction", "Tab2", "Tab3", "Tab4")
tabs[[1]] <- c("Introduction")
tabs[[2]] <- c("Tab2")
tabs[[3]] <- c("Tab3")
tabs[[4]] <- c("Tab4")

ui <- fluidPage(
 navbarPage(title = "Guide to Dirty Data",
            
            #metabolism tab set-up
            tabPanel("Metabolism", 
                    fluidRow(
                         column(8, offset=2,
                                h1("Metabolism"),
                                br(),
                                h3("What is Metabolism"),
                                "Stream metabolism is the measure of energy exchanged within the 
                                stream ecosystem in the forms of oxygen and carbon. The two primary modes
                                of exchange are primary production by autotrophs in which oxygen is produced and
                                carbon dioxide is consumed, and respiration by heterotrophs in which oxygen is consumed
                                carbon dioxide is produced. As research in stream metabolism modeling expands, we can gain
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
                                oxygen produced through gross primary production (GPP) and consumed through ecosystem respiration (ER) to calculate
                                the average metabolism for each day, which can be represented with a curve-fitted oxygen graph
                                as seen below where the observed values are in orange and the curve-fitted data is the solid line. 
                                To obtain this accurate curve fitting and metabolism model, the 
                                oxygen curve must be a complete data set with few gaps. There must also be a high variance
                                in oxygen concentration such as in the oxygen curve below showing data for one day.",
                                HTML('<center><img src="DO curve fit.png", width = 600, height = 350></center>'),
                                br(),
                               
                                #tabsetPanel(id="met_tabs",
                                #       tabPanel(title="Introduction",
                                #                p("This is tab 1")
                                #       ),
                                #       tabPanel(title="Tab2",
                                #                p("This is tab 2")
                                #       ),
                                #       tabPanel(title="Tab3",p("This is tab 3")),
                                #       tabPanel(title="Tab4",p("This is tab 4"))
                                       
                                #),
                                #actionButton(inputId = "prev", "Previous"),
                                #actionButton(inputId = "nex", "Next"),
                                #br(),
                                #br(),
                                #br(),
                                "Below are the dissolved oxygen plots of four streams with their respective metabolism models
                                for 60 days.",
                                br(),
                                br(),
                                HTML('<center><img src="Example DO and Metabolism.png", width = 500, height = 350></center>'),
                                br(),
                                br(),
                                "Once metabolism is calculated and modeled as in the four streams above, there are various ways to visualize the data including 
                                a metabolic fingerprint. This visualization method compares the GPP and ER to observe how the oxygen produced and
                                consumed compare.",
                                HTML('<center><img src="Contour.png", width = 650, height = 350></center>'),
                                br(),
                                "From this comparison through the metabolic fingerprint, a variety of assumptions that can
                                be made about that stream or section of stream that branch from the relationship between respiration
                                and primary production. The primary factors of streams that affect the relationship between
                                GPP and ER are light intensity, nutrients available, heat, sediments, and the flow of water. The impacts of each of these
                                factors on GPP and ER can be seen below with the arrows directed towards the impact of increasing each factor.",
                                br(),
                                br(),
                                HTML('<center><img src="Metabolism.png", width = 350, height = 350></center>'),
                                br()
                               
                                
                            )
                                
                       )
            ),
            
            #Clean Data tab set-up
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
                                              choices = c("Day", "Week", "Month")
                                  )
                                ),
                                mainPanel(
                                  h1("Ideal Data for Modeling Metabolism"),
                                  br(),
                                  textOutput("selected_clean"),
                                  br(),
                                  plotOutput("plot_DO"),
                                  br(),
                                  plotOutput("plot_disc"),
                                  br(),
                                  plotOutput("metab_plot")
                                )
                              )
                          )
                     )
                     
            ),
            
            #Dirty Data tab set-up
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
                                              choices = c("Storm", "Outliers", "Gaps", "Sensor Error", "Sensor Out of Water"))
                
                                ),
                                mainPanel(
                                  h1("Examples and Explanations of Dirty Data"),
                                  br(),
                                  textOutput("dirty_type"),
                                  tags$head(tags$style("#dirty_type{color: black;
                                     font-size: 24px;
                                     font-style: bold;
                                     }")),
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

server <- function(input, output, session) {
  clean_type <- reactive({(input$cleanVar)})
  dirty_file <- reactive({(input$dirtyVar)})
  time_gap <- reactive({(input$time_int)})
  dirty_choice <- reactive({(input$dirtyType)})

  #Metabolism page: model walkthrough "Previous" button
  observeEvent(input$prev, {
     curr_tab = match(input$met_tabs, tabs)
     if(curr_tab > 1){
       prev_tab = tabs[[curr_tab-1]]
     }
     else{
       prev_tab = curr_tab
     }
     updateTabsetPanel(session=session, inputId ="met_tabs",selected=tabs[[prev_tab]])
     
  })
  
  #Metabolism page: model walkthrough "Next" button
  observeEvent(input$nex, {
    curr_tab = match(input$met_tabs, tabs)
    if(curr_tab < 4){
      next_tab = tabs[[curr_tab+1]]
    }
    else{
      next_tab = curr_tab
    }
    updateTabsetPanel(session=session, inputId ="met_tabs",selected=tabs[[next_tab]])
  })
  
  
  output$selected_clean <- renderText({ 
    paste("Below is an oxygen curve considered to be clean and complete for the time period of a", tolower(clean_type()), "at 
          Black Earth Creek in Wisconsin:")
  })
  
  output$plot_DO <- renderPlot({
    clean <- read.csv(paste0(clean_type(), "_DO.csv"))
    df <- data.frame(
      date = as.POSIXct(clean$dateTimeUTC, format="%Y-%m-%d %H:%M:%S"),
      value = clean$value
    )
    ggplot() +
      ggtitle(paste(clean_type(), "of Dissolved Oxygen Data"))+
      xlab("Date")+
      ylab("DO (mgL)")+
      geom_point(df, mapping=aes(x=date, y=value))+
      scale_x_datetime(breaks = date_breaks("2 days"),    
                       labels = date_format("%m-%d"))+
      theme(
        plot.title = element_text( size=17, face="bold"),
        axis.title.x = element_text(size=14, face="bold"),
        axis.title.y = element_text(size=14, face="bold")
      )
  })
  
  output$plot_disc <- renderPlot({
    clean <- read.csv(paste0(clean_type(), "_Discharge.csv"))
    df <- data.frame(
      date = as.POSIXct(clean$dateTimeUTC, format="%Y-%m-%d %H:%M:%S"),
      value = clean$value
    )
    ggplot() +
      ggtitle(paste(clean_type(), "of Discharge Data"))+
      xlab("Date")+
      ylab(bquote('Discharge ('~m^3~g~')'))+
      geom_point(df, mapping=aes(x=date, y=value))+
      scale_x_datetime(breaks = date_breaks("2 days"),    
                       labels = date_format("%m-%d"))+
      theme(
        plot.title = element_text( size=17, face="bold"),
        axis.title.x = element_text(size=14, face="bold"),
        axis.title.y = element_text(size=14, face="bold")
      )
  })
  
  output$metab_plot <- renderPlot({
    clean <- read.csv(paste0(clean_type(), "_metab.csv"))
    if(clean_type() == "Day"){
      return(NULL)
    }
    df <- data.frame(
      date = as.Date(clean$solar_date),
      GPP = clean$GPP,
      GPP_upper = clean$GPP_upper,
      GPP_lower = clean$GPP_lower,
      ER = clean$ER,
      ER_upper = clean$ER_upper,
      ER_lower = clean$ER_lower
    )
    ggplot(data=df, aes(x=date)) +
      geom_line(aes(y=GPP, group = 1, colour="GPP"))+
      geom_line(aes(y=ER,  group = 1, colour = "ER"))+
      geom_ribbon(aes(ymin=df$GPP_lower, ymax=df$GPP_upper, group=1, fill="GPP 95% Confidence"), fill = "red", alpha=0.25)+
      geom_ribbon(aes(ymin=df$ER_lower, ymax=df$ER_upper, group=1, fill="ER 95% Confidence"), fill = "blue", alpha=0.25)+
      scale_colour_manual(name="Oxygen Variables", values=c("ER"="blue","GPP"="red"))+
      scale_fill_manual(name="Oxygen Variables",values=c("GPP 95% Confidence"="red", "ER 95% Confidence"="blue"))+
      ggtitle(paste(clean_type(), "of Metabolism Data"))+
      scale_x_date(limits = as.Date(c(clean_dates[[clean_type()]][1],clean_dates[[clean_type()]][2]))) +
      xlab("Date")+
      ylab(bquote('g' ~O[2]~ m^-2~d^-1))+
      theme(
        plot.title = element_text( size=17, face="bold"),
        axis.title.x = element_text(size=14, face="bold"),
        axis.title.y = element_text(size=14, face="bold"),
        legend.position = "bottom"
      )
    
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
      ggtitle(paste("DO Data with", choice, "from", dirty_loc[[choice]][2], "in", dirty_loc[[choice]][1]))+
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
    if(choice == "Outliersre"){
      return(NULL)
    }
    disch <- read.csv(paste0(choice, "_discharge.csv"))
    df_disch <- data.frame(
      date = as.POSIXct(disch$dateTimeUTC, tz='', 
                        format = "%Y-%m-%d %H:%M:%S"),
      values = disch$value
    )
    ggplot() +
        ggtitle(paste("Discharge Data with", choice, "from", dirty_loc[[choice]][2], "in", dirty_loc[[choice]][1]))+
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
    paste(dirty_info[[dirty_choice()]])
  })
}

shinyApp(ui = ui, server = server)
