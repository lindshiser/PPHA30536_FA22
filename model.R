library(tidyverse)
library(stargazer)

setwd("/Users/lindsayhiser/Documents/Harris/4_FA22/Data and Programming - R II/final-project-lindsay-hiser")
df <- read_csv("data/data.csv")

df <- df %>%
  filter(type != 'index') %>% # remove national averages from df
  mutate(cohort = as.character(cohort), 
         year = as.character(year))

# impact of internet access on average score
fit_lm <- lm(value ~ perc_schoolage_both + year + cohort + subject + type, data = df)
summary(fit_lm)

# impact of internet access on difference in score from 2019-2022
df_diff <- df %>%
  pivot_wider(names_from = 'year', values_from = 'value') %>%
  rename(score_22 = "2022",
         score_19 = "2019") %>%
  mutate(score_diff = score_22 - score_19)

fit_lm_diff <- lm(score_diff ~ perc_schoolage_both + cohort + subject + type, data = df_diff)
summary(fit_lm_diff)
