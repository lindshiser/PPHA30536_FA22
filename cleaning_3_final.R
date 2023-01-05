library(tidyverse)

setwd("/Users/lindsayhiser/Documents/Harris/4_FA22/Data and Programming - R II/final-project-lindsay-hiser")

# access cleaned data
access <- read_csv("data/access.csv")
scores <- read_csv("data/scores.csv")

df <- right_join(access, scores, by = c('place' = 'name'))

df <- df %>%
  select(place, code, type, geo_id, everything()) %>%
  arrange(place)

write_csv(df, "data/data.csv")
