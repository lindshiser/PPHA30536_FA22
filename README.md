# Data and Programming for Public Policy II - R Programming

## Final Project: Reproducible Research
### Lindsay Hiser, Autumn 2022

GitHub repository: [final-project-lindsay-hiser](https://github.com/lindshiser/data-programming-pubpol).

For my project, I study whether household internet access impacts American school-age students’ test scores. Specifically, I analyze the change in average test scores between 2019 and 2022, a measure which has widely been reported as an indicator of negative outcomes resulting from the COVID-19 pandemic. Given the uptake in remote learning methods during the pandemic, I posit that states or cities with greater shares of households with internet access would also have less extreme declines in test scores. 

## Data Cleaning

I collected data on household internet access from the [American Community Survey, 5-Year Estimates](https://www.census.gov/programs-surveys/acs). In [cleaning_1_access.R](https://github.com/lindshiser/data-programming-pubpol/blob/main/cleaning_1_access.R), I retrieved data with a unique Census API key for fifty states and five major school districts in America. Variables included total counts and population shares for households with (1) both internet access and a computer, (2) a computer only, or (3) neither internet access nor a computer. These variables were duplicated for households with school age children. I clean the data so that each observation includes measures of internet access for a unique place.

I collected data on test scores from the [National Assessment of Educational Progress (NAEP)](https://nces.ed.gov/nationsreportcard/), also known as the “nation’s report card.”  In [cleaning_2_scores.R](https://github.com/lindshiser/data-programming-pubpol/blob/main/cleaning_2_scores.R), I declare my variables of interest, notably cohort (fourth and eighth grade), subject (mathematics and reading), and year (2019 and 2022). I then declare the places for which I intend to collect data, including the fifty states and five largest cities in America. I also collect data on national averages. Data was retrieved using multiple API calls for various groupings, defined as a place, grade, subject, and year. I clean the data so that each observation includes the average score for each grouping.

Both of the data wrangling tasks described above included use of APIs, which was a new practice for me. I was, however, motivated to extract data using APIs for both, given the extensive documentation provided by each source. I believe this decision saved me time as the project went on, and it increased my confidence in using APIs in the future.

In [cleaning_3_final.R](https://github.com/lindshiser/data-programming-pubpol/blob/main/cleaning_3_final.R), I merge the two cleaned datasets on the variable place. This final data is exported as data.csv, and will be used in further analysis.

## Exploratory Analysis and Visualizations

My first set of plots visualize the difference in average scores for city and states between 2019 and 2022. In [plots_shiny.R](https://github.com/lindshiser/data-programming-pubpol/blob/main/plots_shiny.R), I create two interactive visualizations that allow users to manipulate by grade level and subject. The first visualizes the difference in scores in major cities, using a slope chart. I found a slope chart to be most useful for visualizing the difference between scores. I decided against using a slope chart for states, however, as the number of states included would overwhelm the visualization. Instead, I visualized the difference in scores in states using a choropleth map. I used a continuous and diverging color scheme, to capture both the negative and positive values in score differences. While most scores had a decrease in average score, there were a few states who had score increases, particularly in reading. You can view screenshots of those interactive plots [here](https://github.com/lindshiser/data-programming-pubpol/blob/main/images/shiny_cities.png) and [here](https://github.com/lindshiser/data-programming-pubpol/blob/main/images/shiny_states.png).

In [plots_static.R](https://github.com/lindshiser/data-programming-pubpol/blob/main/plots_static.R), I create my second set of plots, which visualize the relationship between scores and household internet access. My [first static plot](https://github.com/lindshiser/data-programming-pubpol/blob/main/images/average_score_by_access.png) visualizes the relationship between household internet access and average scores in states. I choose to use the ‘percentage of households with school age children and internet access’ as my independent variable, given that my project focuses on school test scores. I use the `facet_wrap` function to visualize this relationship for each unique grouping, based on subject and grade level, simultaneously. 

My [second static plot](https://github.com/lindshiser/data-programming-pubpol/blob/main/images/diff_score_by_access.png) visualizes the relationship between household internet access and average scores. Like my first plot, I use the `facet_wrap` function to compare different groupings. I created a new variable, `score_diff`, that quantifies the difference in score between 2019 and 2022 for each grouping, whether positive or negative. 

## Text Processing

My text processing task was inspired by my first interactive chart that visualized the difference in scores in 2019 and 2022 in five major cities. Understanding that some cities faced steeper declines in average scores than others, I wanted to explore whether these negative outcomes were reflected in negative sentiments in the news reporting in that city. 

In [text_processing.R](https://github.com/lindshiser/data-programming-pubpol/blob/main/text_processing.R), I selected five articles to represent each of the major cities. Each article was published on October 23-24, 2022, a day or so after the 2022 NAEP scores were available to the public. Each article was published on a local news site. I used web-scraping tools to parse each article, separated the parsed html text into tokens, then used the tokens to analyze the sentiments of each article. I compared sentiments between cities using NRC and AFINN sentiments, visualized in static plots [here](https://github.com/lindshiser/data-programming-pubpol/blob/main/images/reporting_sentiment_nrc.png) and [here](https://github.com/lindshiser/data-programming-pubpol/blob/main/images/reporting_sentiment_afinn.png).

## Modeling
In [model.R](https://github.com/lindshiser/data-programming-pubpol/blob/main/model.R), I fit a basic linear model to my data on test scores and internet access. To more clearly understand the extent of any relationship between average test scores and internet access, I used linear regression to predict average test score based on the share of households with internet access. I controlled for year, grade, subject, and type of place (i.e. city or state). This model was similar to my [first static plot](https://github.com/lindshiser/data-programming-pubpol/blob/main/images/average_score_by_access.png).

I also used linear regression to predict the difference in average test score between 2019 and 2020 based on the share of households with internet access. Like the first model, controlled for grade, subject, and type of place. This model was similar to my [second static plot](https://github.com/lindshiser/data-programming-pubpol/blob/main/images/diff_score_by_access.png).

## Results and Future Research

In analyzing the difference in test scores between 2019 and 2020, I find that there were declines in scores for all groupings. In my [second shiny plot](https://github.com/lindshiser/data-programming-pubpol/blob/main/images/shiny_states.png), we see that across most states, the largest score drops were in mathematics, for both grades.

In my [first shiny plot](https://github.com/lindshiser/data-programming-pubpol/blob/main/images/shiny_cities.png), all cities faced declines in test scores for both subjects and grades, with the exception of Los Angeles, who increased their scores in all areas except 4th grade mathematics. Philadelphia, by comparison, had steep declines to already low average scores. Oddly enough, news reporting done in Philadelphia was the most positive of all the cities, with an average AFINN value of 0.621.

In my models, I find that there is a significant, albeit small, relationship between internet access and average test scores. Namely, that a one percentage point increase in the share of households (with school age children) with internet access results in a 1.02-point increase in average test score. This result is significant, with a p-value of < 0.001. This result is visualized in my [first static plot](https://github.com/lindshiser/data-programming-pubpol/blob/main/images/average_score_by_access.png).

I also find that a shift in year from 2019 to 2022 results in a 5.02 decrease in score, on average, and that average scores reported for states are, on average, 8.89 points higher than average scores reported for cities.

Finally, I find that a one-percentage point increase in the share of households (with school age children) with internet access results in -0.07 difference in scores between 2019 and 2020. This result, however, was not reported as significant. This finding makes sense, given that the results visualized in my [second static plot](https://github.com/lindshiser/data-programming-pubpol/blob/main/images/diff_score_by_access.png) were also unclear.

One threat to the integrity of this project’s results is the notion that internet access may be correlated with other variables that better explain average test scores. To avoid this omitted variable bias, future research should seek to include these confounding variables when fitting the data to a model.
