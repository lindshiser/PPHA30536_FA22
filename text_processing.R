library(tidyverse)
library(tidytext)
library(readr)
library(rvest)

setwd("/Users/lindsayhiser/Documents/Harris/4_FA22/Data and Programming - R II/final-project-lindsay-hiser")

df <- tibble(city = c("Chicago", "Houston", "Los Angeles", "New York City", "Philadelphia"),
             url = c("https://chicago.chalkbeat.org/2022/10/23/23417098/naep-nations-report-card-chicago-public-schools-math-reading-scores",
                      "https://www.houstonchronicle.com/news/houston-texas/education/article/Houston-students-test-scores-plummet-compared-to-17527509.php",
                      "https://www.latimes.com/california/story/2022-10-24/california-test-scores-pandemic-drops",
                      "https://ny.chalkbeat.org/2022/10/24/23417176/naep-nyc-math-reading-scores-drop-pandemic-remote-learning-academic-recovery",
                      "https://www.penncapital-star.com/education/sobering-but-not-surprising-report-details-the-pandemics-toll-on-philly-students-test-scores/"),
             text = "" # to fill with text
)


parser <- function(url) { # to parse urls
  res <- read_html(url)
  list <- as.list(html_nodes(res, 'p'))
  vecs <- html_text(list)
  string <- str_c(vecs, collapse = "")
  return(string)
}

texts <- list() # create new list to store texts
for (url in df$url) { 
  texts[url] <- parser(url)
}

tokens <- unnest_tokens(tibble(city = df$city,
                               text = texts), # create tibble with city and texts
                        word_tokens, 
                        text, 
                        token = "words")

sentiments <- tokens %>%
  left_join(get_sentiments("nrc"), by = c("word_tokens" = "word")) %>% # assign sentiment(s) to tokens
  left_join(get_sentiments("afinn"), by = c("word_tokens" = "word")) %>%
  rename(nrc = sentiment,
         afinn = value) %>%
  anti_join(stop_words, by = c("word_tokens" = "word"))

# histogram for sentiment of reporting by city - afinn
sentiment_afinn <- sentiments %>%
  filter(!is.na(afinn)) %>%
  ggplot(aes(x = afinn, fill = city)) +
  geom_histogram(position = "dodge", stat = "count") +
  scale_x_continuous(n.breaks = 7) +
  labs(title = "Sentiment of Reporting About NAEP Scores (AFINN)",
       subtitle = "One news article evaluated per city, published October 23-24, 2022",
       y = "Word count") +
  theme(plot.title = element_text(hjust = 0.5)) + # source: https://stackoverflow.com/questions/40675778/center-plot-title-in-ggplot2
  theme(plot.subtitle = element_text(hjust = 0.5)) +
  theme(legend.title = element_blank())
print(sentiment_afinn)
ggsave("images/reporting_sentiment_afinn.png", sentiment_afinn)


# histogram for sentiment of reporting by city - nrc
sentiment_nrc <- sentiments %>%
  filter(!is.na(nrc)) %>%
  ggplot(aes(x = nrc, fill = city)) +
  geom_histogram(position = "dodge", stat = "count") +
  scale_x_discrete(guide = guide_axis(angle = 45)) +
  labs(title = "Sentiment of Reporting About NAEP Scores (NRC)",
       subtitle = "One news article evaluated per city, published October 23-24, 2022",
       x = element_blank(), 
       y = "Word count") +
  theme(plot.title = element_text(hjust = 0.5)) + # source: https://stackoverflow.com/questions/40675778/center-plot-title-in-ggplot2
  theme(plot.subtitle = element_text(hjust = 0.5)) +
  theme(legend.title = element_blank())
print(sentiment_nrc)
ggsave("images/reporting_sentiment_nrc.png", sentiment_nrc)

# calculate mean afinn value for each city
sentiments %>%
  filter(!is.na(afinn)) %>%
  group_by(city) %>%
  summarise(mean_afinn = mean(afinn)) %>%
  arrange(desc(mean_afinn)) # rank highest to lowest value
  print()
