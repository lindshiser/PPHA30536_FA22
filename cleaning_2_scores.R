library(tidyverse)
library(httr) # get API
library(jsonlite) # get API

setwd("/Users/lindsayhiser/Documents/Harris/4_FA22/Data and Programming - R II/final-project-lindsay-hiser")

urls <- tibble( # df to store api urls for later use
  type = 'data',
  subject = c('mathematics', 'mathematics', 'mathematics', 'mathematics', 'reading', 'reading', 'reading', 'reading'),
  cohort = c('1', '1', '2', '2', '1', '1', '2', '2'),
  subscale = c('MRPCM', 'MRPCM', 'MRPCM', 'MRPCM', 'RRPCM', 'RRPCM', 'RRPCM', 'RRPCM'),
  variable = 'TOTAL',
  jurisdiction = '', # leave blank to be filled in later
  stattype = 'MN:MN',
  year = c('2019', '2022', '2019', '2022', '2019', '2022', '2019', '2022'),
  url = '',
  value = ''
)

jurisdictions <- tibble( # codebook
  code = c('AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 
           'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
           'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
           'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 
           'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
           'NT', 'NP', 'NL', # 'national', 'national public', 'large city'
           'XN', 'XL', 'XC', 'XH', 'XP'), # city names
  name = c('Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 
            'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
            'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 
            'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 
            'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri',
            'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 
            'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 
            'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 
            'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 
            'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming',
            'National', 'National Public', 'Large City',
            'New York City', 'Los Angeles', 'Chicago', 'Houston', 'Philadelphia')
)

scores <- list() # create empty list

for (code in jurisdictions$code) { # assign each state a template df
  scores[[code]] <- urls
  scores[[code]]$jurisdiction <- code
}
 
# create url for each group (subj-cohort-year) within each state
base_url <- ('https://nationsreportcard.gov/Dataservice/GetAdhocData.aspx?type=%s&subject=%s&cohort=%s&subscale=%s&variable=%s&jurisdiction=%s&stattype=%s&Year=%s')
for (code in jurisdictions$code) {
  scores[[code]]$url <- sprintf(base_url, scores[[code]]$type, scores[[code]]$subject, scores[[code]]$cohort, 
                                scores[[code]]$subscale, scores[[code]]$variable, scores[[code]]$jurisdiction, 
                                scores[[code]]$stattype, scores[[code]]$year)
}

get_value <- function(url) { # to get average score for each group within state
  res <- GET(url)
  rawToChar(res$content)
  data <- fromJSON(rawToChar(res$content))
  result <- data$result
  result$value
}

# run function, storing group scores in respective state tibbles
# source: https://www.geeksforgeeks.org/how-to-create-a-nested-for-loop-in-r/
i <- 1
for (code in jurisdictions$code) {
  for (i in 1:8) {
    scores[[code]]$value[i] <- get_value(scores[[code]]$url[i])
    i = i + 1
  }
}

df <- scores %>%
  map(as_tibble) %>%
  reduce(bind_rows) %>%
  select(jurisdiction, cohort, subject, year, value)

df$value <- as.numeric(df$value)

df <- df %>%
  rename(code = jurisdiction) %>%
  mutate(type = ifelse(code == 'XN' |
                       code == 'XL' |
                       code == 'XC' |
                       code == 'XH' |
                       code == 'XP', 'city', 'state'),
         type = ifelse(code == 'NT' |
                       code == 'NP' |
                       code == 'NL', 'index', type)) %>%
  left_join(jurisdictions, by = 'code') %>%
  select(name, code, type, everything())

write_csv(df, 'data/scores.csv')
