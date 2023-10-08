# UI
# You can run the application by clicking 'Run App' above.
# But PLEASE follow the instructions given in README.md
# And install all the required packages via "Package Install Commands.Rmd"

# Importing libraries
library(shiny)
library(shinythemes)
library(fontawesome)
library(shinyWidgets)
library(shinydashboard)
library(igraph)
library(highcharter)
library(dashboardthemes)
source('helper.R')

header <- dashboardHeader(
  # Define the header and insert image as title
  title = tags$a(tags$img(src='https://bit.ly/3cSvLu7',
                          height='40', width='160')),
  titleWidth = 280
)

sidebar <- dashboardSidebar(
  width = 280,
  sidebarMenu(
    # Tab for different visualisation
    menuItem("Home",
             tabName = "home",
             selected = T,
             icon = fa_i('fas fa-house')),
    menuItem("An Alarming Timeline",
             tabName = "timeline",
             icon = fa_i("fas fa-timeline")),
    menuItem("Shooter And Intention",
             tabName = "shooter",
             icon = fa_i("fas fa-handcuffs")),
    menuItem("School",
             tabName = "school",
             icon = fa_i("fas fa-school"))
  )
)

body <- dashboardBody(
  customTheme,
  tabItems(
    # Structure for home tab
    tabItem("home",
            fluidPage(
              # Title for home tab
              titlePanel(strong("Overview of US School Shooting Incidents 
                 Since the 99 Columbine High Massacre")),
              hr(),
              h5(strong("The Sad Statistics Since the Columbine Massacre"),
                 style = "font-size:16px;"),
              
              # Value box
              fluidRow(
                column(3, valueBoxOutput("incident_1", width = 14)),
                column(3, valueBoxOutput("student_1", width = 14)),
                column(3, valueBoxOutput("kill_1", width = 14)),
                column(3, valueBoxOutput("injury_1", width = 14))
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
                            min = 1999, max = 2022, value = c(1999, 2022), sep = "")
              ),
              mainPanel(
                highchartOutput("school_map", height = 505)
              )
            ),
            hr(),
            h5('Data Source: ', 
               a("The Washington Post", 
                 href="https://github.com/washingtonpost/data-school-shootings")),
            h5('Charts and map are created using ', 
               a("Highcharter", 
               href="https://jkunst.com/highcharter/"), 
               '(a R wrapper for Highcharts)')
    ),
    
    tabItem("timeline",
            fluidPage(
              titlePanel(strong("An Alarming Timeline")),
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
                   href="https://github.com/washingtonpost/data-school-shootings")),
              h5('Charts and map are created using ', 
                 a("Highcharter", 
                   href="https://jkunst.com/highcharter/"), 
                 '(a R wrapper for Highcharts)')
            )
    ),
    
    tabItem("shooter",
            fluidPage(
              titlePanel(strong("Shooter And Intention")),
              hr(),
              
              # Use fluid row layout to put two plots side by side
              fluidRow(
                column(6, highchartOutput("shooter_age")),
                column(6, highchartOutput("weapon_source"))
              ),
              hr(),
              h4("As depicted in the plot on the left, over 55% of shooters with a known age fall 
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
                   href="https://github.com/washingtonpost/data-school-shootings")),
              h5('Charts and map are created using ', 
                 a("Highcharter", 
                   href="https://jkunst.com/highcharter/"), 
                 '(a R wrapper for Highcharts)')
            )
    ),
    tabItem("school",
            fluidPage(
              titlePanel(strong("School")),
              hr(),
              fluidRow(
                column(5, highchartOutput("public_private")),
                column(7, highchartOutput("school_type"))
              ),
              hr(),
              h4("As depicted in the pie chart on the left, nearly 94% of the shooting incidents 
                 occurred in public schools. However, we must consider the fact that there are more 
                 public schools than private schools. The bar chart on the right shows that over 60% 
                 of the incidents happened in high schools, followed by elementary schools with 14.5%. 
                 Nevertheless, local governments and schools should take more effective actions to 
                 reduce the risk of school shootings.", 
                 style = "color: #808080;font-size:15px;"),
              hr(),
              h5('Data Source: ', 
                 a("The Washington Post",
                   href="https://github.com/washingtonpost/data-school-shootings")),
              h5('Charts and map are created using ', 
                 a("Highcharter", 
                   href="https://jkunst.com/highcharter/"), 
                 '(a R wrapper for Highcharts)')
            )
    )
  )
)

# Putting the UI together
ui <- dashboardPage(
  title = "GEOM90007 Dashboard",
  header, 
  sidebar, 
  body
)
