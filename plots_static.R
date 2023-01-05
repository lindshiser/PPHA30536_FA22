library(tidyverse)

setwd("/Users/lindsayhiser/Documents/Harris/4_FA22/Data and Programming - R II/final-project-lindsay-hiser")
df <- read_csv("data/data.csv")

# for facet relabelling
group_names <- list( # create labels for group (i.e. subject-0cohort) names, to be declared later
  "mathematics_1" = "4th grade mathematics",
  "mathematics_2" = "8th grade mathematics",
  "reading_1" = "4th grade reading",
  "reading_2" = "8th grade reading"
)

group_labeller <- function(variable, value) { # to rename facet labels
  return(group_names[value])
}

# facet line chart plotting average score, by access
facet_average <- df %>%
  filter(type == "state") %>%
  unite(group, c(subject, cohort)) %>% # https://www.statology.org/r-combine-two-columns-into-one/
  ggplot(aes(x = perc_schoolage_both, y = value, color = as.character(year))) +
  geom_point() +
  geom_smooth(method = 'lm') +
  facet_wrap(~group, labeller = group_labeller) + # rename facet labels using declared list
  labs(title = str_wrap("Across states, household internet access is positively related
                        with average scores regardless of grade, subject, or year", 50),
       x = "Share of households* with internet access",
       y = "Average score",
       color = "Year",
       caption = "*With schoolage children. Source: NAEP, U.S. Census Bureau") +
  theme(plot.title = element_text(hjust = 0.5)) # source: https://stackoverflow.com/questions/40675778/center-plot-title-in-ggplot2
print(facet_average)
ggsave("images/average_score_by_access.png", facet_average)


# facet line chart plotting difference in score, by access
facet_diff <- df %>%
  filter(type == "state") %>%
  unite(group, c(subject, cohort)) %>%
  pivot_wider(names_from = year, values_from = value) %>%
  rename(year_22 = "2022",
         year_19 = "2019") %>%
  mutate(diff = year_22 - year_19) %>%
  ggplot(aes(x = perc_schoolage_both, y = diff)) + # source to reorder: https://www.programmingwithr.com/how-to-arrange-ggplot-barplot-bars-in-ascending-or-descending-order/
  geom_point() +
  geom_smooth(method = 'lm') +
  facet_wrap(~group, labeller = group_labeller) +
  labs(title = str_wrap("Across states, difference in average scores between 2019 and 2022 is not clearly 
                        related to household internet access", 50),
       x = "Share of households* with internet access",
       y = "Difference in average scores",
       color = "Year",
       caption = "*With schoolage children. Source: NAEP, U.S. Census Bureau") +
  theme(plot.title = element_text(hjust = 0.5)) # source: https://stackoverflow.com/questions/40675778/center-plot-title-in-ggplot2
print(facet_diff)
ggsave("images/diff_score_by_access.png", facet_diff)

