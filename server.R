# Server

# Importing libraries
library(shiny)
library(stringr)
library(shinythemes)
library(fontawesome)
library(shinydashboard)
library(igraph)
library(highcharter)
library(dplyr)
library(tidyr)
library(dashboardthemes)
source('helper.R')

# Set a global theme highcharter plot
options(highcharter.theme = hc_theme_hcrt())

server <- shinyServer(function(input, output) {
  
  ##################################### Home #####################################
  
  output$school_map <- renderHighchart({
    
    # Filter dataset based on the selection made by the user
    map_data <- dataset %>%
      filter(type_of_school %in% input$school_filter) %>%
      filter(state %in% input$map_state) %>%
      filter(between(year, input$map_filter[1], input$map_filter[2])) %>%
      select(school_name, type_of_school, state, city, date, casualties, lat, long) %>%
      # Sort data to create visual hierarchy to overlayed bubbles
      arrange(desc(casualties))

    # Rename columns
    colnames(map_data) <- c('school_name', 'type_of_school', 'states', 'city', 
                            'date', 'z', 'lat', 'lon')
    
    # plot chart using the filtered data
    highchart(type = "map") %>%
      hc_exporting(enabled = TRUE) %>%
      
      # Add map polygons
      hc_add_series(name = "usmap", mapData = usa, showInLegend = FALSE,
                    dataLabels = list(enabled = TRUE, color = '#878787', 
                                      format = '{point.properties.postal-code}')) %>%
      hc_add_series(data = map_data, name = "School", "mapbubble", maxSize = "7%") %>%
      hc_chart(backgroundColor = "#D8F9FF") %>%
      # Define sequential colour scheme
      hc_colorAxis(minColor = '#FEB5B1', maxColor = '#6A0500') %>%
      hc_plotOptions(polygon = list(color = "#ddead1")) %>%
      hc_legend(title = list(text = "Casualties"),
                bubbleLegend = list(enabled = TRUE)) %>%
      
      # Define tooltip information for user hover
      hc_tooltip(pointFormat = '<b>{point.school_name}</b>
                 <br/><b>School Type:</b> {point.type_of_school} <br/>
                 <b>Location:</b> {point.city}, {point.states} <br/>
                 <b>Date:</b> {point.date} <br/>
                 <b>Casualties:</b> {point.z}') %>%
      hc_mapNavigation(enabled = TRUE) %>%
      hc_title(text = "Shooting Incident Locations and Severity <small>(Hover for more detail)</small>", 
               useHTML = T)
  })
  
  ############################# An Alarming Timeline #############################
  
  output$year_casualty <- renderHighchart({
    # Summarise dataset for visualization
    temp_data <- dataset %>%
      group_by(year) %>%
      summarise(across(c("killed", "injured"), sum))
    
    # Count incidents in every year
    incident_year_count <- dataset %>%
      count(year)
    
    # Define color options
    col <- c('#FBE106', '#8080FF', '#D21404')
    
    # Plot line and column bar chart
    highchart() %>%
      hc_exporting(enabled = TRUE) %>%
      hc_title(text = "Number of Victims and Incidents Between 1999 and 2023") %>%
      hc_subtitle(text = 'Source: <a href="https://github.com/washingtonpost/data-
                  school-shootings" target="_blank">The Washington Post</a>') %>%
      hc_chart(zoomType = "x") %>%
      hc_yAxis_multiples(list(title = list(text = "Number of Victims"), showLastLabel = TRUE, opposite = FALSE),
                         list(title = list(text = "Number of Incidents"), opposite = TRUE)) %>%
      hc_xAxis(title = list(text = "Year")) %>%
      hc_add_series(incident_year_count, name = "Incident Count", "column", 
                    hcaes(x = year, y = n), yAxis = 1) %>%
      hc_plotOptions(series = list(borderRadius = 4, animation = list(duration = 3000))) %>%
      hc_add_series(temp_data, name = "Injured", "spline", hcaes(x = year, y = injured)) %>%
      hc_add_series(temp_data, name = "Killed", "spline", hcaes(x = year, y = killed)) %>%
      hc_colors(col) %>%
      
      # Use shared tooltips
      hc_tooltip(crosshairs = TRUE, shared = TRUE)
  })
  
  ############################# Shooter and Intention ############################
  
  output$shooter_age <- renderHighchart({
    
    # Classified shooter age into groups
    age_binned <- findInterval(c(filter(dataset, !is.na(age_shooter1))$age_shooter1,
                                 filter(dataset, !is.na(age_shooter2))$age_shooter2), 
                               c(0, 10, 15, 20, 30, 40))
    
    # Rename groups and define hue for each group
    shooter_age <- data.frame("age" = age_binned) %>%
      count(age) %>%
      mutate(freq = round(n/sum(n), 3)*100) %>%
      mutate(age = recode(age, "1" = "Age 0-9", "2" = "Age 10-14", "3" = "Age 15-19",
                          "4" = "Age 20-29", "5" = "Age 30-39", 
                          "6" = "Age 40+"))
    shooter_age['col'] <- c("#00FFFF", "#34006A", "#BC544B", "#DFFE00", "#0000FF", "#FFA500")
    
    # Plot circular item chart
    shooter_age %>%
      hchart("item", hcaes(name = age, y = n, color = col), name = "Number of shooters",
             showInLegend = TRUE, center = list("50%", "70%"), size = "100%",
             startAngle = -100, endAngle  = 100) %>%
      hc_exporting(enabled = TRUE) %>%
      hc_title(text = "School Shooter Age Distribution") %>%
      hc_subtitle(text = 'Source: <a href="https://github.com/washingtonpost/data-
                  school-shootings" target="_blank">The Washington Post</a><br/>
                  Omitted 114 shooters with unspecified age') %>%
      # Define hover tooltips
      hc_tooltip(pointFormat = 'Number of shooters: <b>{point.n}</b>
                 <br/>Accounted for <b>{point.freq}%</b> of all known age shooters') %>%
      hc_legend(labelFormat = '{name} <span style="opacity: 0.5">{y}</span>')
  })
  
  output$weapon_source <- renderHighchart({
    dataset %>%
      
      # Filter out rows that aren't relevant to the analysis
      filter(!is.na(age_shooter1), between(age_shooter1, 10, 19), 
             !is.na(source_of_weapon), source_of_weapon != "") %>%
      
      # Count, sort, and calculate percentage for each category
      count(source_of_weapon) %>%
      arrange(n) %>%
      mutate(freq = round(n/sum(n), 3)) %>%
      
      # Render the chart
      hchart("pie", innerSize = '60%', hcaes(x = source_of_weapon, y = freq*100),
             showInLegend = TRUE, 
             dataLabels = list(enabled = TRUE),
             allowPointSelect = TRUE) %>%
      hc_title(text = "Source of Weapon for Age 10-19 Shooters") %>%
      hc_subtitle(text = 'Source: <a href="https://github.com/washingtonpost/data-school-shootings" target="_blank">The Washington Post</a><br/>
                Omitted 282 records with unspecified weapon source') %>% 
      hc_tooltip(pointFormat = 'Weapon Source: <b>{point.source_of_weapon}</b><br/>
               Accounted for <b>{point.y}%</b> of all specified weapon source') %>%
      hc_exporting(enabled = TRUE) %>%
      hc_legend(labelFormat = '{name} <span style="opacity: 0.5">{n}</span>')
  })

  
  output$shooter_intention <- renderHighchart({
    # Prepare data
    temp_data <- dataset %>%
      mutate(shooting_type = str_to_title(gsub(",", " ", shooting_type))) %>%
      # Rename values to a better format
      mutate(shooting_type = 
               recode(shooting_type, "Public Suicide (Attempted)" = "Public Suicide",
                      "Targeted And Indiscriminate" = "Targeted and Indiscri.")) %>%
      
      # Group shooting intention and summarise casualties for each intention
      group_by(shooting_type) %>%
      summarise(casual = sum(casualties), n = n()) %>%
      mutate(freq = round(n/sum(n) * 100, 2)) %>%
      arrange(n)
    
    # Define color code
    col <- c('#FBE106', '#D21404')
    
    # Plot bar chart and line chart
    highchart() %>%
      hc_exporting(enabled = TRUE) %>%
      hc_title(text = "Shooter Intention and Casualties") %>%
      hc_subtitle(text = 'Source: <a href="https://github.com/washingtonpost/data-
                  school-shootings" target="_blank">The Washington Post</a>') %>%
      hc_yAxis_multiples(list(title = list(text = "Number of Casualties"), showLastLabel = TRUE, opposite = FALSE),
                         list(title = list(text = "Number of Incidents"), opposite = TRUE)) %>%
      hc_add_series(temp_data, name = "Shooting Intention", "column",
                    hcaes(x = shooting_type, y = n), yAxis = 1,
                    tooltip = list(pointFormat = 'Number of Incidents Recorded: <b>{point.n}</b>
                                   <br/>Accounted for <b>{point.freq}%</b> of all incidents')) %>%
      hc_add_series(temp_data, name = "Casualties", "spline",
                    hcaes(x = shooting_type, y = casual),
                    tooltip = list(pointFormat = "<br/>Number of Casualties: <b>{point.casual}</b>")) %>%
      hc_xAxis(categories = temp_data$shooting_type, title = list(text = "Shooting Intention")) %>%
      hc_plotOptions(series = list(borderRadius = 4)) %>%
      # Use shared tooltips for both chart
      hc_tooltip(shared = TRUE) %>%
      hc_colors(col)
  })
  
  #################################### School ####################################
  
  output$public_private <- renderHighchart({
    dataset %>%
      
      # Mutate attributes for a better format
      mutate(school_type = recode(school_type, "private" = "Private School", "public" = "Public School")) %>%
      # Group and count by School type
      count(school_type) %>%
      # Calculate percentages of count
      mutate(freq = round(n/sum(n), 3)) %>%
      
      # Plotting
      hchart("pie", innerSize = '60%', hcaes(x = school_type, y = freq*100), showInLegend = TRUE, 
             dataLabels = list(enabled = FALSE), allowPointSelect = TRUE) %>%
      hc_exporting(enabled = TRUE) %>%
      
      # Define hue for the two groups
      hc_colors(c('#0000FF', '#FF0000')) %>%
      hc_title(text = "Risk: Public vs Private School") %>%
      hc_subtitle(text = 'Source: <a href="https://github.com/washingtonpost/data-
                  school-shootings" target="_blank">The Washington Post</a>') %>%
      # Define tooltip information
      hc_tooltip(pointFormat = 'Number of Incidents Recorded: <b>{point.n}</b><br/>
                 Involved in <b>{point.y:.1f}%</b> of gun shooting incidents') %>%
      hc_legend(labelFormat = '{name} <span style="opacity: 0.4">{n}</span>')
  })
  
  output$school_type <- renderHighchart({
    # Filter and construct dataset for plotting
    dataset %>%
      count(type_of_school) %>%
      # Obtain percentage and sort
      mutate(freq = round(n/sum(n), 3)*100) %>%
      # Sort data frame by count values in descending order
      arrange(desc(n)) %>%
      hchart("bar", hcaes(x = type_of_school, y = n)) %>%
      hc_exporting(enabled = TRUE) %>%
      hc_plotOptions(series = list(
        borderRadius = 4,
        color = "#FF0000",
        dataLabels = list(
          enabled = TRUE,
          color = "#000000",
          formatter = JS("function() { return this.y }")
        )
      )) %>%
      hc_title(text = "Type of School Involved in Shooting Incidents") %>%
      hc_subtitle(text = 'Source: <a href="https://github.com/washingtonpost/data-school-shootings" target="_blank">The Washington Post</a>') %>%
      hc_xAxis(title = list(text = "School Type")) %>%
      hc_yAxis(title = list(text = "Number of Incidents")) %>%
      # Define hover tooltips
      hc_tooltip(pointFormat = 'Number of Incidents Recorded: <b>{point.n}</b>
                 <br/>Accounted for <b>{point.freq}%</b> of all incidents')
  })
  
  output$shooting_time <- renderHighchart({
    all_hours <- data.frame(shooting_hour = 0:23)
    
    hourly_counts <- dataset %>%
      group_by(shooting_hour) %>%
      summarise(count = n(), .groups = 'drop')
    
    complete_hourly_counts <- all_hours %>%
      left_join(hourly_counts, by = "shooting_hour") %>%
      # Replace NA with 0 for hours without any shootings
      replace_na(list(count = 0))

    hchart(complete_hourly_counts, "column", hcaes(x = shooting_hour, y = count)) %>%
      hc_title(text = "Shooting Counts by Hour") %>%
      hc_subtitle(text = 'Source: <a href="https://github.com/washingtonpost/data-
                  school-shootings" target="_blank">The Washington Post</a>') %>%
      hc_exporting(enabled = TRUE) %>%
      hc_plotOptions(series = list(borderRadius = 4, color = "#FF0000")) %>%
      hc_xAxis(title = list(text = "Hour of the Day"), categories = as.character(all_hours$shooting_hour)) %>%
      hc_yAxis(title = list(text = "Number of Incidents")) %>%
      hc_plotOptions(column = list(dataLabels = list(enabled = TRUE))) %>%
      hc_tooltip(pointFormat = 'Number of Incidents Recorded: <b>{point.count}</b>')
  })
  
  output$enrolment_incidents <- renderHighchart({
    bin_width <- 500  # Adjust this value based on the distribution of enrollment numbers in your data
    bins <- seq(0, max(dataset$enrollment, na.rm = TRUE) + bin_width, by = bin_width)
    dataset$enrollment_bin <- cut(dataset$enrollment, breaks = bins, include.lowest = TRUE, labels = FALSE)

    incident_counts <- dataset %>%
      filter(!is.na(enrollment_bin)) %>%  # Remove rows where enrollment_bin is NA
      group_by(enrollment_bin) %>%
      summarise(incidents = n(), .groups = 'drop') %>%
      mutate(
        midpoint = (enrollment_bin - 1) * bin_width + bin_width / 2
      )
    
    highchart() %>%
      hc_chart(type = "scatter", zoomType = "xy") %>%
      hc_title(text = "Enrollment vs. Number of Incidents") %>%
      hc_subtitle(text = "Scatter plot showing if larger schools tend to have more incidents") %>%
      hc_xAxis(title = list(text = "Enrollment Size of School")) %>%
      hc_yAxis(title = list(text = "Number of Incidents")) %>%
      hc_tooltip(headerFormat = "<b>{series.name}</b><br>", pointFormat = "Enrollment Size: <b>{point.x}</b><br>Incidents: <b>{point.y}</b>") %>%
      hc_add_series(data = incident_counts %>% mutate(x = midpoint, y = incidents) %>% select(x, y) %>% list_parse(), name = "Incidents", 
                    color = "#FF0000", marker = list(radius = 5)) %>%
      hc_exporting(enabled = TRUE)  # Enable exporting the chart
  })
})