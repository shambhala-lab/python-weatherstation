library(DBI)
library(shiny)
library(ggplot2)
library(lubridate)
library(tidyverse)
library(shinydashboard)


##########################
## ESTABLISH CONNECTION ##
##########################
# elephantsql.com (Weather station)
weather <-  dbConnect(drv = RPostgres::Postgres(),
                     host = "tiny.db.elephantsql.com",
                     dbname = "bzfjdjpk",
                     user = "bzfjdjpk",
                     password = "GQS3YNEdkvfl6oj8zo2-KHrQ0U1fSKch")


ui <- dashboardPage(
  dashboardHeader(title = ("WEATHER STATION")),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem(("Graph"), tabName = "tab1", icon = icon("fas fa-chart-line")),
      menuItem(("Data logs"), tabName = "tab2", icon = icon("fas fa-scroll")),
      menuItem(("Dashboard"), tabName = "tab3", icon = icon("fas fa-tachometer-alt")),
      dateRangeInput("dayrange", ("Date range"), language = "th", start = Sys.Date(), end = Sys.Date()+1 ))
    ),
  
  dashboardBody(
      tabItems(
        tabItem(tabName = "tab1", h2("Graph"),
            plotOutput("graph")
        ),
        
        tabItem(tabName = "tab2", h2("Raw Data Logger"),
            fluidRow(
              box(title = ("Station 1"), width = 12, solidHeader = TRUE, status = "primary",
                fluidRow(
                  column(width = 6,
                         tableOutput("table"))))
            )
        ),

        tabItem(tabName = "tab3", h2("Dashboard"),
            fluidRow(
              column(9,
                     valueBoxOutput("maxtemp"),
                     valueBoxOutput("meantemp"),
                     valueBoxOutput("mintemp"))),

            fluidRow(
              column(9,
                     valueBoxOutput("maxpress"),
                     valueBoxOutput("meanpress"),
                     valueBoxOutput("minpress")))
            
        )
        
      )
    )
)

server <- function(input, output, session) {
  
  ######################
  # DATABASE FUNCTIONS #
  ######################
  DB_READ <- function(query){    
    reply <- dbSendQuery(weather, query)
    data <- dbFetch(reply)
    dbClearResult(reply)
    data
  }
  
  ####################################
  # TRANSFORM DATETIME - THAI LOCALE #
  ####################################
  THAIDAY <- function(day){
    day <- as.character(day)
    yyyy <- year(day) + 543
    mm <- month(day, label = TRUE, abbr = TRUE)
    dd <- mday(day)

    hr <- hour(day)
    hr <- str_pad(as.character(hr), 2, pad = "0")
    mt <- minute(day)  
    mt <- str_pad(as.character(mt), 2, pad = "0")
    
    thaiday <- paste0(dd, " ", mm, " ", yyyy, " - ", hr, ":", mt)
    thaiday <- str_replace(thaiday, "\\\\", "")
  }  

  ###############
  # FORMAT DAYS #
  ###############
  CONV2THAI <- function(data){    
    if(nrow(data) == 0)
      data <- data.frame(matrix(ncol = 0, nrow = 0))
    else{
      for(i in 1:ncol(data)){
        column <- names(data)[i]
        if(str_detect(column, 'calendar')) 
          data[[column]] <- THAIDAY(data[[column]])
      }
    }
    data
  }  
  
  #########################
  # FORMAT DATA PRECISION #
  #########################
  PRECESION <- function(m){
    formatC(m, format="f", digits=2, big.mark=",")
  }    
  
  #####################
  # FILTER DATE RANGE #
  #####################
  FILTER_PR_DATE <- function(data,date1,date2){
    data <- filter(data, calendar >= date1)
    data <- filter(data, calendar <= date2)
  }    
  
  
  output$graph <- renderPlot({
    data <- data_range()
    ggplot(data=data, aes(x=calendar, y=temperature, group=1)) +
    # ggplot(data=data, aes(x=calendar, y=pressure, group=1)) +
      geom_line(linetype="solid", color="orange", size=1)
      
      # apply below line for same y axis
      # geom_line(aes(y=pressure), linetype="solid", color="cyan", size=1)

  }, res = 96)

  dayrange <- reactive(input$dayrange)
  
  data_range <- reactive({
    query <- paste("SELECT * FROM station1 ORDER BY calendar")
    data <- DB_READ(query)

    # Filtering By DATE RANGE
    data <- FILTER_PR_DATE(data, dayrange()[1], dayrange()[2])
    data    
  })

  interval    <- reactive(Sys.Date() - input$day)
  current     <- reactive(paste0("NOW() AT TIME ZONE 'Asia/Bangkok' - INTERVAL", " '", interval() ," DAY'"))
  temperature <- reactive(input$temp)
  pressure    <- reactive(input$press)
  
  observeEvent(input$save,{
    frame <- data_range()[1,]
    column_list <- paste(colnames(frame), collapse = ",")
    
    value_list <- paste(current(),temperature(),pressure(), sep = ",")
    
    insert <- paste0("INSERT INTO station1 (", column_list , ") VALUES (", value_list, ")")
    dbSendQuery(weather, insert)
  })
  
  output$table <- renderTable({
    data <- data_range()
    data <- CONV2THAI(data)
    data
  }, width = "100%", striped = TRUE, spacing = "xs", na = "")
  

  dashboard <- reactiveValues(maxtemp = 0, maxpress = 0, meantemp = 0, meanpress = 0, mintemp = 0, minpress = 0)
  
  observeEvent(input$dayrange,{
    data <- data_range()
    
    dashboard$maxtemp  <-  paste(PRECESION(max(data$temperature)), "ยฐ C")
    dashboard$maxpress <-  paste(PRECESION(max(data$pressure)), "hPa")
    
    dashboard$meantemp  <-  paste(PRECESION(mean(data$temperature)), "ยฐ C")
    dashboard$meanpress <-  paste(PRECESION(mean(data$pressure)), "hPa")
    
    dashboard$mintemp  <-  paste(PRECESION(min(data$temperature)), "ยฐ C")
    dashboard$minpress <-  paste(PRECESION(min(data$pressure)), "hPa")
    
  })    

  # valueBox color
  #red    yellow    aqua    blue     light-blue    green    
  #navy    teal    olive    lime    orange    fuchsia    purple
  
  # fas fa-thermometer-full
  # fas fa-thermometer-half
  # fas fa-wind
  # fas fa-compress-arrows-alt
  # fas fa-snowflake
  
  # 1020 hPa ความกดอากาศสูง อากาศหนาว* ใช้สัญญลักษณ์ H สีเขียว
  # 1015 hPa ความกดอากาศสูง อากาศเย็น * ใช้สัญญลักษณ์ H สีเขียว
  # 1013 hPa ความกดอากาศปกติ 1 บรรยากาศ (atm)
  # 1010 hPa ความกดอากาศต่ำ * ใช้สัญญลักษณ์ L สีแดง  
  
  
  # TEMPERATURE
  output$maxtemp <- renderValueBox({
    valueBox(dashboard$maxtemp, "Max Temperature", color = "orange", icon = icon("fas fa-temperature-high"))
  })

  output$meantemp <- renderValueBox({
    valueBox(dashboard$meantemp, "Average Temperature", color = "olive", icon = icon("fas fa-thermometer-half"))
  })
  
  output$mintemp <- renderValueBox({
    valueBox(dashboard$mintemp, "Min Temperature", color = "green", icon = icon("fas fa-snowflake"))
  })    
  
  # PRESSURE
  output$maxpress <- renderValueBox({
    valueBox(dashboard$maxpress, "Max Pressure", color = "blue", icon = icon("fas fa-compress-arrows-alt"))
  })

  output$meanpress <- renderValueBox({
    valueBox(dashboard$meanpress, "Average Pressure", color = "light-blue", icon = icon("fas fa-compress"))
  })  

  output$minpress <- renderValueBox({
    valueBox(dashboard$minpress, "Min Pressure", color = "aqua", icon = icon("fas fa-compress-alt"))
  })
}

shinyApp(ui, server)