library(shiny)
library(fpp3)
library(tsibble)
library(seasonal)
library(plotly)
library(forecast)
  
  Bigfoot_locations <- read.csv("bfro_locations.csv")
  Bigfoot_locations <- Bigfoot_locations %>%
    mutate(timestamp = as.Date(timestamp))
  Bigfoot_locations_tsibble <- tsibble(Bigfoot_locations, index = timestamp, key = number)
  Bigfoot_tsibble_2000_onwards <- Bigfoot_locations_tsibble %>%
    filter(year(timestamp) >= 2000)
  monthly_aggregate <- Bigfoot_locations_tsibble %>%
    mutate(month = yearmonth(timestamp)) %>%
    count(month, name = "sightings")
  
  subset_2000_to_2024 <- monthly_aggregate %>%
    filter(month >= yearmonth("2000-01") & month <= yearmonth("2024-03"))
  
  Bigfoot_locations_tsibble2000_to_2024 <- as_tsibble(subset_2000_to_2024, index = month) %>%
    fill_gaps(sightings = 0)
  
  if (nrow(Bigfoot_locations_tsibble2000_to_2024) >= 24) {
    
    Bigfoot_x11_components <- Bigfoot_locations_tsibble2000_to_2024 %>%
      model(X_13ARIMA_SEATS(sightings ~ x11())) %>%
      components()
    
  } else {
    message("Not enough data points for decomposition")
  }
  
  ui <- fluidPage(
    tags$head(
      tags$style(HTML("
        body {
          background-color: #F0F8FF; /* Alice Blue color */
        }
      "))
    ),
    # Title
    div(style = "text-align: center;", 
        titlePanel("Hide and Seek Champion Sightings in the 21st Century: An Analysis of Bigfoot Sighting Data")
    ),
    
    # General Paragraph
    HTML("<p>Please note that the graphs and map might take some time to load.<br>
  The following app takes a look at a portion of a dataset from Kaggle.com pertaining to Bigfoot sightings.  The portion includes dates from January 1, 2000 to the most recent data.<br>
  The dataset can be found at https://www.kaggle.com/datasets/chemcnabb/bfro-bigfoot-sighting-report.<br>
  
  Five sections can be accessed from the tabs at the top of the screen.<br> 
  The first shows our unaltered information.  It is simply the number of times each month a sighting of Bigfoot was recorded.<br>
  The second displays three ways of looking at the data from a seasonal standpoint.  These can be toggled between using radio buttons under the Choose Graph: heading.<br>
  The third displays how each month compares to other months.<br>
  The fourth tab shows a decomposition of our data into seasonal, trend, and irregular components.<br>
  Month and year of each point can be seen by hovering your cursor over the point on the graph. <br>
  The fifth tab includes forecasts for two years after our data.  The radio buttons allow for examination of four different methods of prediction. <br>
  At the bottom of each page, there is a world map that allows for further inspection into the series.  If there is a specific time in the data that you would like to investigate, that time frame can be selected within the Date Range.
  That range will be reflected in the timeline at the bottom of the screen.  By pressing play, an animation will begin that shows the locations of sightings during that month.  To pause or search within the animation, you can click or drag the circle on the timeline.  The map can be zoomed in on by using the buttons in the top right corner of the map section.<br>
  My analysis of each section is below the plots for that tab.
  </p>"),
  
  # Tabset for Full Series, Seasonality, ACF, and Full Decomposition
  tabsetPanel(
    # Full Series Tab
    tabPanel("Full Series",
             fluidRow(
               column(12, plotlyOutput("BigfootSeriesPlot"))
             ),
             HTML("<p>Our initial investigation of the time series gives us some insight into what is happening with the data.  We see that there is a range of sightings between 0 and 37.  The series appears to fluctuate sporadically and trend down over the course of time.</p>")
    ),
    
    # Seasonality Tab
    tabPanel("Seasonality",
             radioButtons("seasonalityGraphType", "Choose Graph:",
                          choices = c("Seasonality Plot" = "x13",
                                      "Series Grouped by Months" = "subseries",
                                      "Series Grouped by Years" = "season")),
             fluidRow(
               column(12, plotlyOutput("seasonalityPlot"))
             ),
             HTML("<p>Our investigation of seasonality appears to show that seasonality
                  fluctuates less as the series progresses through time.  This is supported
                  by the plot that groups by month because our higher values appear to be in 
                  earlier years.  The plot that groups by year is very busy, but we can see a 
                  little bit of a pattern with high points at the beginning, almost exactly in 
                  the middle, and at the end.</p>")
    ),
    
    # ACF Tab
    tabPanel("ACF",
             fluidRow(column(12, plotlyOutput("x13AutocorrelationPlot"))),
             HTML("The  ACF or Autocorrelation Function compares the similarity of the months.
                  The graph shows that the most similarity comes from the next year, followed by 
                  the year after that.  The least similarity comes from 5 months away, follow by 
                  17 months away.  This implies yearly seasonality.")
    ),
    
    # Full Decomposition Tab
    tabPanel("Full Decomposition",
             fluidRow(column(12, plotlyOutput("x13DecompositionPlot"))),
             HTML("<p>The full decomposition shows a decreasing trend over time,
                  which is what we expected to see from the full series.  The spike 
                  in trend early in the series isn’t readily apparent up front but makes
                  sense upon a comparison between the trend line and the full series.  
                  The seasonality mirrors what we concluded from the seasonality analysis. 
                  The residuals in the irregular plot look to me like there is still a slight
                  pattern in how the plot increases and decreases.  I think there might be an 
                  aspect of seasonality that wasn’t explained by seasonality, perhaps seasonality
                  on a scale smaller than yearly.</p>")
  ),
  # Forecast Tab
  tabPanel("Forecast",
           radioButtons("forecastGraphType", "Choose Graph:",
                        choices = c("Exponential Smoothing Model" = "ets",
                                    "ARIMA Model" = "arima",
                                    "Seasonal Naive Model" = "snaive",
                                    "Time Series Linear Model" = "tslm")),
           fluidRow(column(12, plotOutput("forecastPlot"))),
           HTML("<p>Among the four forecasting methods, the Exponential Smoothing
                Model is my preferred choice. When predicting the last two years
                of recorded data, the ARIMA model showed a marginally smaller 
                average error per sighting, about 0.03 less than the Exponential
                Smoothing model. However, the Exponential Smoothing model was 
                approximately 15% more precise in capturing the overall trend and
                seasonal patterns compared to the ARIMA model. This means it more
                accurately reflected the ups and downs seen in the actual data. 
                While both ARIMA and Exponential Smoothing are good options, I 
                prefer the Exponential Smoothing model for its ability to more 
                closely follow the variations in reported sightings.</p>")
    )
  ),
  
  # Date Range Selector
  fluidRow(
    column(12, 
           dateRangeInput("dateRange", 
                          label = "Select Date Range:",
                          start = as.Date("2000-01-01"),
                          end = as.Date("2021-11-30"))
    )
  ),
  
  # Map
  fluidRow(
    column(12,
           plotlyOutput("map", height = "600px")
    )
  )
  )
  
  server <- function(input, output) {
    
    output$BigfootSeriesPlot <- renderPlotly({
      autoplot(Bigfoot_locations_tsibble2000_to_2024)
    })
    
    output$seasonalityPlot <- renderPlotly({
      req(input$seasonalityGraphType) # Ensure that the input exists
      
      if (input$seasonalityGraphType == "x13") {
        Bigfoot_x11_components %>%
          autoplot(seasonal)
      } else if (input$seasonalityGraphType == "subseries") {
        gg_subseries(Bigfoot_locations_tsibble2000_to_2024)
      } else if (input$seasonalityGraphType == "season") {
        enhanced_data <- Bigfoot_locations_tsibble2000_to_2024 %>%
          mutate(year = year(month),
                 month_label = month(month, label = TRUE))
        
        plot_ly(data = enhanced_data, x = ~month_label, y = ~sightings, color = ~factor(year),
                type = 'scatter', mode = 'lines+markers',
                hoverinfo = 'text',
                text = ~paste(month_label, year, "Sightings:", sightings))
      }
    })
    
    output$x13AutocorrelationPlot <- renderPlotly({
      Bigfoot_x11_components %>%
        ACF() %>%
        autoplot()
    })
    
    output$x13DecompositionPlot <- renderPlotly({
      Bigfoot_x11_components %>%
        autoplot()
    })
    
    
    output$forecastPlot <- renderPlot({
      req(input$forecastGraphType)  # Ensure that input is available
      
      
      tryCatch({
        if (input$forecastGraphType == "arima") {
          model_fit <- Bigfoot_locations_tsibble2000_to_2024 %>%
            model(ARIMA(box_cox(sightings, lambda = 0.231)))
        } else if (input$forecastGraphType == "ets") {
          model_fit <- Bigfoot_locations_tsibble2000_to_2024 %>%
            model(ETS(box_cox(sightings, lambda = 0.231)))
        } else if (input$forecastGraphType == "snaive") {
          model_fit <- Bigfoot_locations_tsibble2000_to_2024 %>%
            model(SNAIVE(sightings))
        } else if (input$forecastGraphType == "tslm") {
          model_fit <- Bigfoot_locations_tsibble2000_to_2024 %>%
            model(TSLM(sightings ~ trend() + season()))
        }
        
        future_forecast <- model_fit %>% forecast(h = 24)
        
        future_forecast %>%
          autoplot(Bigfoot_locations_tsibble2000_to_2024, level = NULL)
      })
    })
    
    filtered_data <- reactive({
      Bigfoot_tsibble_2000_onwards %>%
        filter(timestamp >= input$dateRange[1] & timestamp <= input$dateRange[2])
    })
    
    output$map <- renderPlotly({
      animated_data <- filtered_data() %>%
        mutate(date = as.character(timestamp))
      
      plot_ly(data = animated_data, lat = ~latitude, lon = ~longitude, type = 'scattergeo', mode = 'markers',
              text = ~paste("Date:", date), hoverinfo = 'text', frame = ~date) %>%
        layout(
          geo = list(
            scope = 'north america',
            showland = TRUE,
            landcolor = "rgb(217, 217, 217)",
            subunitcolor = "rgb(255, 255, 255)",
            countrycolor = "rgb(255, 255, 255)",
            countrywidth = 0.5,
            subunitwidth = 0.5,
            projection = list(type = 'mercator')
          )
        ) %>%
        animation_opts(frame = 1000, redraw = TRUE) %>%
        animation_slider(currentvalue = list(prefix = "Date: ")) %>%
        animation_button(
          buttons = list(
            list(method = "animate", args = list(NULL, list(frame = list(duration = 1000, redraw = TRUE), mode = "immediate")), label = "Play"),
            list(method = "animate", args = list(NULL, list(mode = "pause")), label = "Pause")
          ),
          x = 0.1, y = 0, xanchor = 'right', yanchor = 'top'
        )
    })
  }
  
  shinyApp(ui, server)
