library(tidyverse)
library(sf)
library(shiny)
library(plotly)

ui <- fluidPage(
  fluidRow( # row 1 title
    column(width = 12,
           align = "center",
           tags$h1("How did the COVID-19 pandemic affect test scores across the country?"),
           tags$hr()
           )
  ),
  
  fluidRow( # row 2 subtitle
    column(width = 12,
           align = "center",
           tags$h4("Difference in average scores by major city")
           ) 
  ),
  
  fluidRow( # row 3 selectors
    column(width = 6,
           align = "center",
           selectInput(inputId = "grade_sl",
                       label = "Choose a grade level",
                       choices = c("4th grade",
                                   "8th grade"))
    ),
    
    column(width = 6,
           align = "center",
           selectInput(inputId = "subj_sl",
                       label = "Choose a subject",
                       choices = c("Mathematics", "Reading"))
    )
  ),
  
  fluidRow( # row 4 chart
    column(width = 12,
           plotlyOutput("slope")
           )
  ),
  
  fluidRow( # row 5 caption source
    column(width = 12,
           align = "right",
           tags$em(tags$p("Source: NAEP, U.S. Census Bureau")),
           tags$hr()
           )
  ),
  
  fluidRow( # row 6 subtitle
    column(width = 12,
           align = "center",
           tags$h4("Difference in average scores by state"),
           )
  ),
  
  fluidRow( # row 7 selectors
    column(width = 6,
           align = "center",
           selectInput(inputId = "grade_mp",
                       label = "Choose a grade level",
                       choices = c("4th grade",
                                   "8th grade"))
    ),
    
    column(width = 6,
           align = "center",
           selectInput(inputId = "subj_mp",
                       label = "Choose a subject",
                       choices = c("Mathematics", "Reading"))
    )
  ),
  
  fluidRow( # row 8 chart
    column(width = 12,
           align = "center",
           plotlyOutput("map")
    )
  ),
  
  fluidRow( # row 9 caption source
    column(width = 12,
           align = "right",
           tags$em(tags$p("Source: NAEP, U.S. Census Bureau"))
           )
  )
)

server <- function(input, output) {
  path <- "/Users/lindsayhiser/Documents/Harris/4_FA22/Data and Programming - R II/final-project-lindsay-hiser"
  
  df <- read_csv(file.path(path, "data/data.csv"))
  
  build_slope <- function(cohort, subject) {
    slope <- df %>%
      filter(type == "city" & # limit to cities only
             cohort == {{cohort}} & # source: https://thomasadventure.blog/posts/turning-your-ggplot2-code-into-a-function/
             subject == {{subject}}) %>%
      ggplot(aes(as.character(year), value, group = place)) + # source: https://www.rdocumentation.org/packages/CGPfunctions/versions/0.6.3/topics/newggslopegraph
      geom_line(aes(color = place), size = 1) +
      geom_point(aes(color = place), size = 3) +
      theme_minimal() +
      labs(
        x = "Year",
        y = "Average score",
      )
    return(slope)
  }
  
  us_shape <- st_read(file.path(path, "shapefiles/cb_2021_us_state_20m.shp"))
  
  df_geo <- df %>%
    left_join(us_shape, by = c("geo_id" = "AFFGEOID")) %>%
    select(place, type, geo_id, cohort, subject, year, value, geometry) %>%
    filter(type == 'state' & # limit to states only
             place != 'Alaska' & # limit to continental US
             place != 'Hawaii')
  df_sf <- st_sf(df_geo)
  
  build_choropleth <- function(cohort, subject) {
    map <- df_sf %>%
      pivot_wider(names_from = 'year', values_from = 'value') %>%
      rename(score_22 = "2022",
             score_19 = "2019") %>%
      mutate(score_diff = score_22 - score_19) %>%
      filter(cohort == {{cohort}} &
             subject == {{subject}}) %>%
      ggplot() +
      geom_sf(aes(fill = score_diff)) +
      scale_fill_distiller(palette = "RdBu", # source: https://ggplot2.tidyverse.org/reference/scale_brewer.html
                           direction = 1,
                           breaks = c(-15, 0, 15),
                           limits = c(-15, 15)) + # source: https://ggplot2.tidyverse.org/reference/continuous_scale.html
      labs(fill = str_wrap("Difference in average scores", 10)) + # legend
      theme_void()
    return(map)
  }
    
  output$slope <- renderPlotly({
    if (input$grade_sl == "4th grade" & input$subj_sl == "Mathematics") {
      slope <- build_slope("1", "mathematics")
      ggplotly(slope)
    } else if (input$grade_sl == "4th grade" & input$subj_sl == "Reading") {
      slope <- build_slope("1", "reading")
      ggplotly(slope)
    } else if (input$grade_sl == "8th grade" & input$subj_sl == "Mathematics") {
      slope <- build_slope("2", "mathematics")
      ggplotly(slope)
    } else if (input$grade_sl == "8th grade" & input$subj_sl == "Reading") {
      slope <- build_slope("2", "reading")
      ggplotly(slope)
    }
  })
  
  output$map <- renderPlotly({
    if (input$grade_mp == "4th grade" & input$subj_mp == "Mathematics") {
      map <- build_choropleth("1", "mathematics")
      ggplotly(map)
    } else if (input$grade_mp == "4th grade" & input$subj_mp == "Reading") {
      map <- build_choropleth("1", "reading")
      ggplotly(map)
    } else if (input$grade_mp == "8th grade" & input$subj_mp == "Mathematics") {
      map <- build_choropleth("2", "mathematics")
      ggplotly(map)
    } else if (input$grade_mp == "8th grade" & input$subj_mp == "Reading") {
      map <- build_choropleth("2", "reading")
      ggplotly(map)
    }
  })
  
}

shinyApp(ui = ui, server = server)
