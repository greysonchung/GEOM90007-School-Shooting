# Importing libraries
library(shiny)
library(shinythemes)
library(fontawesome)
library(shinyWidgets)
library(igraph)
library(highcharter)
library(bslib)
thematic::thematic_shiny(font = "auto")
source('helper.R')

ui <- page_navbar(
  title = "Post-Columbine",
  theme = bs_theme(
    bootswatch = "cerulean",
    navbar_bg = "#d3d3d3"
  ),
  nav_spacer(),
  nav_panel("Home",
            fluidPage(
              # Title for home tab
              titlePanel("Overview of US School Shooting Incidents 
                 Since the 99 Columbine High Massacre"),
              hr(),
              h5(strong("Critical Figures: Key Statistics in the Wake of the Columbine Tragedy"),
                 style = "font-size:16px;"),
              
              # Value box
              layout_columns(
                value_box(
                  title = "Total Incident Count",
                  value = dim(dataset)[1],
                  theme = "bg-gradient-purple-cyan",
                  showcase = bsicons::bs_icon("hash"),
                  showcase_layout = "top right"
                ),
                value_box(
                  title = "Students Endangered",
                  value = sum(dataset$enrollment),
                  theme = "bg-gradient-orange-indigo",
                  showcase = bsicons::bs_icon("people"),
                  showcase_layout = "top right"
                ),
                value_box(
                  title = "Fatalities",
                  value = sum(dataset$killed),
                  theme = "bg-gradient-red-indigo",
                  showcase = bsicons::bs_icon("hospital"),
                  showcase_layout = "top right"
                ),
                value_box(
                  title = "Injuries",
                  value = sum(dataset$injured),
                  theme = "bg-gradient-teal-indigo",
                  showcase = bsicons::bs_icon("bandaid"),
                  showcase_layout = "top right"
                )
              ),
              hr(),
              
              # Adapt sidebar layout for the map visualization
              sidebarLayout(
                sidebarPanel(
                  # Define filter and options for the user
                  pickerInput("map_state", 
                              tags$p(fa("filter", fill = "forestgreen"), 
                                     "State filter for visualisation"),
                              state_choiceVec, selected = state_choiceVec, 
                              multiple = TRUE, options = list(`actions-box` = TRUE)),
                  checkboxGroupInput("school_filter", 
                                     tags$p(fa("filter", fill = "forestgreen"),
                                            "School type filter"),
                                     school_type_choiceVec, selected = school_type_choiceVec),
                  sliderInput("map_filter", 
                              tags$p(fa("filter", fill = "forestgreen"),
                                     "Select a time period for visualisation"),
                              min = 1999, max = 2024, value = c(1999, 2024), sep = "")
                ),
                mainPanel(
                  highchartOutput("school_map", height = "100%")
                )
              ),
              hr(),
              h5('Data Source: ', 
                 a("The Washington Post", 
                   href="https://github.com/washingtonpost/data-school-shootings"),
                 style = "font-size:16px;"),
              h5('Charts and map are created using ', 
                 a("Highcharter", 
                   href="https://jkunst.com/highcharter/"), 
                 '(a R wrapper for Highcharts)',
                 style = "font-size:16px;")
            )
  ),
  nav_panel("Timeline",
            fluidPage(
              titlePanel("An Alarming Timeline"),
              hr(),
              # Define highcharter output
              highchartOutput("year_casualty", height = 485),
              hr(),
              h4("School shootings have been occurring every year since the 1999 Columbine massacre. The 
                 number of casualties peaked in 2018 with a horrifying record of 95 casualties. The number 
                 of incidents and casualties significantly reduced in 2020, which might be primarily due to 
                 school closures during the pandemic. However, the number of incidents skyrocketed in 2021, 
                 with a record-breaking 42 shooting incidents occurring that year.",
                 style = "color: #808080;font-size:15px;"),
              hr(),
              h5('Data Source: ', 
                 a("The Washington Post", 
                   href="https://github.com/washingtonpost/data-school-shootings"),
                 style = "font-size:16px;"),
              h5('Charts and map are created using ', 
                 a("Highcharter", 
                   href="https://jkunst.com/highcharter/"), 
                 '(a R wrapper for Highcharts)',
                 style = "font-size:16px;")
            )
  ),
  nav_panel("Shooter and Intention",
            fluidPage(
              titlePanel("Shooter And Intention"),
              hr(),
              
              # Use fluid row layout to put two plots side by side
              fluidRow(
                column(6, highchartOutput("shooter_age")),
                column(6, highchartOutput("weapon_source"))
              ),
              hr(),
              h4("As depicted in the plot on the left, 58% of shooters with a known age fall 
                 between 15 and 19 years old, followed by those aged 10 to 14, who constitute almost
                 20%. The plot on the right indicates that for those aged between 10 and 19, over 
                 70% obtained their weapons from relatives. Thus, adults should be more vigilant and 
                 limit minors' access to firearms. Conversely, the plot below reveals that over 55% 
                 of shooting incidents were targeted. However, indiscriminate firing results in the 
                 highest number of casualties, surpassing the combined total of other categories.",
                 style = "color: #808080;font-size:15px;"),
              hr(),
              fluidRow(
                column(12, highchartOutput("shooter_intention"))
              ),
              hr(),
              h5('Data Source: ', 
                 a("The Washington Post", 
                   href="https://github.com/washingtonpost/data-school-shootings"),
                 style = "font-size:16px;"),
              h5('Charts and map are created using ', 
                 a("Highcharter", 
                   href="https://jkunst.com/highcharter/"), 
                 '(a R wrapper for Highcharts)',
                 style = "font-size:16px;")
            )
  ),
  nav_panel("School",
            fluidPage(
              titlePanel("School"),
              hr(),
              fluidRow(
                column(5, highchartOutput("public_private")),
                column(7, highchartOutput("school_type"))
              ),
              hr(),
              h4("As depicted in the pie chart on the left, nearly 94% of the shooting incidents 
                 occurred in public schools. However, we must consider the fact that there are more 
                 public schools than private schools. The bar chart on the right shows that over 60% 
                 of the incidents happened in high schools, followed by elementary schools with 14.2%. 
                 Nevertheless, local governments and schools should take more effective actions to 
                 reduce the risk of school shootings.", 
                 style = "color: #808080;font-size:15px;"),
              hr(),
              fluidRow(
                column(6, highchartOutput("shooting_time")),
                column(6, highchartOutput("enrolment_incidents"))
              ),
              hr(),
              h5('Data Source: ', 
                 a("The Washington Post", 
                   href="https://github.com/washingtonpost/data-school-shootings"),
                 style = "font-size:16px;"),
              h5('Charts and map are created using ', 
                 a("Highcharter", 
                   href="https://jkunst.com/highcharter/"), 
                 '(a R wrapper for Highcharts)',
                 style = "font-size:16px;")
            )
  ),
  nav_item(
    input_dark_mode(id = "dark_mode", mode = "light")
  )
)
