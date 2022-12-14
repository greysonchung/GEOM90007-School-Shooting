# Helper functions

# Read dataset
dataset <- read.csv("data/school-shootings-data.csv")

# Load geo.json file for the map
usa <- jsonlite::fromJSON("data/us-all.geo.json", simplifyVector = FALSE)


# Theme for dashboard
customTheme <- shinyDashboardThemeDIY(
  ### general
  appFontFamily = "Optima"
  ,appFontColor = "#2D2D2D"
  ,primaryFontColor = "#000000"
  ,infoFontColor = "#000000"
  ,successFontColor = "#0F0F0F"
  ,warningFontColor = "#D41A1A"
  ,dangerFontColor = "#D41A1A"
  ,bodyBackColor = "#FFFFFF"
  
  ### header
  ,logoBackColor = "#FFFFFF"
  
  ,headerButtonBackColor = "#FFFFFF"
  ,headerButtonIconColor = "#000000"
  ,headerButtonBackColorHover = "#CAE0E6"
  ,headerButtonIconColorHover = "#000000"
  
  ,headerBackColor = "#FFFFFF"
  ,headerBoxShadowColor = ""
  ,headerBoxShadowSize = "0px 0px 0px"
  
  ### sidebar
  ,sidebarBackColor = "#F0F0F0"
  ,sidebarPadding = "3"
  
  ,sidebarMenuBackColor = "transparent"
  ,sidebarMenuPadding = "2"
  ,sidebarMenuBorderRadius = 0
  
  ,sidebarShadowRadius = ""
  ,sidebarShadowColor = "0px 0px 0px"
  
  ,sidebarUserTextColor = "#737373"
  
  ,sidebarSearchBackColor = "#FFFFFF"
  ,sidebarSearchIconColor = "#000000"
  ,sidebarSearchBorderColor = "#DCDCDC"
  
  ,sidebarTabTextColor = "#737373"
  ,sidebarTabTextSize = "15"
  ,sidebarTabBorderStyle = "none"
  ,sidebarTabBorderColor = "none"
  ,sidebarTabBorderWidth = "0"
  
  ,sidebarTabBackColorSelected = "#D1D1D1"
  ,sidebarTabTextColorSelected = "#000000"
  ,sidebarTabRadiusSelected = "0px"
  
  ,sidebarTabBackColorHover = "#F5F5F5"
  ,sidebarTabTextColorHover = "#000000"
  ,sidebarTabBorderStyleHover = "none solid none none"
  ,sidebarTabBorderColorHover = "#C8C8C8"
  ,sidebarTabBorderWidthHover = "4"
  ,sidebarTabRadiusHover = "0px"
  
  ### boxes
  ,boxBackColor = "#FFFFFF"
  ,boxBorderRadius = "5"
  ,boxShadowSize = "none"
  ,boxShadowColor = ""
  ,boxTitleSize = "20"
  ,boxDefaultColor = "#E1E1E1"
  ,boxPrimaryColor = "#5F9BD5"
  ,boxInfoColor = "#B4B4B4"
  ,boxSuccessColor = "#70AD47"
  ,boxWarningColor = "#ED7D31"
  ,boxDangerColor = "#E84C22"
  
  ,tabBoxTabColor = "#F8F8F8"
  ,tabBoxTabTextSize = "15"
  ,tabBoxTabTextColor = "#646464"
  ,tabBoxTabTextColorSelected = "#2D2D2D"
  ,tabBoxBackColor = "#F8F8F8"
  ,tabBoxHighlightColor = "#C8C8C8"
  ,tabBoxBorderRadius = "5"
  
  ### inputs
  ,buttonBackColor = "#E2D2FA"
  ,buttonTextColor = "#2D2D2D"
  ,buttonBorderColor = "#FFFFFF"
  ,buttonBorderRadius = "9"
  
  ,buttonBackColorHover = "#BEBEBE"
  ,buttonTextColorHover = "#000000"
  ,buttonBorderColorHover = "#969696"
  
  ,textboxBackColor = "#FFFFFF"
  ,textboxBorderColor = "#6C6C6C"
  ,textboxBorderRadius = "9"
  ,textboxBackColorSelect = "#F5F5F5"
  ,textboxBorderColorSelect = "#6C6C6C"
  
  ### tables
  ,tableBackColor = "#F8F8F8"
  ,tableBorderColor = "#EEEEEE"
  ,tableBorderTopSize = "5"
  ,tableBorderRowSize = "4"
)

# Choice vectors for the filters
state_choiceVec <- c(sort(unique(dataset$state)))
school_type_choiceVec <- c(
  "High School",
  "Kindergarten to Grade 12",
  "Middle-High School",
  "Middle School",
  "Elementary-Middle School",
  "Elementary School",
  "Kindergarten-Elementary School",
  "Pre-Kindergarten",
  "Others"
)
