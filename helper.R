# Helper functions

# Read dataset
dataset <- read.csv("data/school-shootings-data.csv")

# Load geo.json file for the map
usa <- jsonlite::fromJSON("data/us-all.geo.json", simplifyVector = FALSE)

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
