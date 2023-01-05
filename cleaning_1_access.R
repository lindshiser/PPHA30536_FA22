library(tidyverse)
library(httr) # get API
library(jsonlite) # get API

setwd("/Users/lindsayhiser/Documents/Harris/4_FA22/Data and Programming - R II/final-project-lindsay-hiser")

# census api subject examples: https://api.census.gov/data/2020/acs/acs5/subject/examples.html
# by school district, update with api key
res_dis <- GET('api.census.gov/data/2020/acs/acs5/subject?get=NAME,group(S2802)&for=school%20district%20(unified):*&key=YOUR_KEY_GOES_HERE')
rawToChar(res_dis$content)
df_dis <- as.data.frame(
  fromJSON(rawToChar(res_dis$content))
)
colnames(df_dis) <- df_dis[1, ] # replace header with first row of labels
df_dis <- df_dis[-1, ] # remove redundant row of labels
df_dis <- df_dis[ ,-3] # remove redundant name col

# by state, update with api key
res_st <- GET('api.census.gov/data/2020/acs/acs5/subject?get=NAME,group(S2802)&for=state:*&key=YOUR_KEY_GOES_HERE')
rawToChar(res_st$content)
df_st <- as.data.frame(
  fromJSON(rawToChar(res_st$content))
)
colnames(df_st) <- df_st[1, ]
df_st <- df_st[-1, ]
df_st <- df_st[ ,-3]

df_dis <- df_dis[ ,-620] # remove irrelevant row to prepare for merge
df <- rbind(df_dis, df_st)

vars <- tibble(
  code = c('NAME', 'GEO_ID',
           'S2802_C01_001E', 'S2802_C01_002E',
           'S2802_C02_001E', 'S2802_C02_002E',
           'S2802_C03_001E', 'S2802_C03_002E',
           'S2802_C04_001E', 'S2802_C04_002E',
           'S2802_C05_001E', 'S2802_C05_002E',
           'S2802_C06_001E', 'S2802_C06_002E',
           'S2802_C07_001E', 'S2802_C07_002E'),
  var = c('name', 'geo_id',
          'tot_hholds', 'tot_schoolage',
          'tot_hholds_both', 'tot_schoolage_both',
          'perc_hholds_both', 'perc_schoolage_both',
          'tot_hholds_computer', 'tot_schoolage_computer',
          'perc_hholds_computer', 'perc_schoolage_computer',
          'tot_hholds_neither', 'tot_schoolage_neither',
          'perc_hholds_neither', 'perc_schoolage_neither')
  )

places <- tibble(
  code = c(df_st$NAME,
           'New York City Department Of Education, New York',
           'Chicago Public School District 299, Illinois',
           'Los Angeles Unified School District, California',
           'Houston Independent School District, Texas',
           'Philadelphia City School District, Pennsylvania'),
  place = c(df_st$NAME,
            'New York City', 'Chicago', 'Los Angeles', 'Houston', 'Philadelphia')
)

df <- df %>%
  filter(NAME %in% places$code) %>%
  select(any_of(vars$code)) %>%
  setNames(vars$var)
  
df <- df %>%
  left_join(places, by = c('name' = 'code')) %>%
  select(-name) %>%
  select(place, everything())

write_csv(df, "data/access.csv")
