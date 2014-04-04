library(shiny)

data(movies)

shinyUI(
  pageWithSidebar(
    headerPanel("Movies Data"),
    
    sidebarPanel(
      
      radioButtons(
        "mpaa", 
        "MPAA Rating",
        c("All", "NC-17", "PG", "PG-13", "R"),
        selected = c("All")
      ),
      br(),
      
      radioButtons(
        "isAll", 
        "Movie Genres",
        c("(Select All)", "(Clear All)"),
        selected = c("(Select All)")
      ),
      
      checkboxGroupInput(
        "genre", 
        NULL,
        c("Action", "Animation", "Comedy", "Drama", 
          "Documentary", "Romance", "Short"),
        selected = c("Action", "Animation", "Comedy", "Drama", 
                     "Documentary", "Romance", "Short")
      ),
      
      width = 2
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Scatter Plot", 
                 fluidPage(
                   fluidRow(
                     column(10,plotOutput("scatterplot")),
                     column(2,
                            
                            selectInput(
                              "color",
                              "Color Scheme:",
                              c("Default", "Accent", "Set1", "Set2", "Set3", "Dark2", 
                                "Pastel1", "Pastel2")
                            ),
                            
                            sliderInput(
                              "size", 
                              "Dot Size:", 
                              min=0, max=10, value=4, step=1),
                            br(),
                            
                            sliderInput(
                              "alpha",
                              "Dot Alpha:", 
                              min=0, max=1, value=0.8, step=0.1),
                            br(),
                            
                            radioButtons(
                              "type",
                              "Scatter Type:",
                              c("Single", "Multiples"),
                              selected=c("Single")
                            )
                     )
                   )
        )) ,
        tabPanel("Statistic Table", 
                 fluidPage(
                   fluidRow(
                     column(5, 
                       h4("Ratings"),
                       tableOutput("trating")
                     ),
                     column(5, 
                        h4("Budgets in Millions"),
                        tableOutput("tbudget")
                     )
                  ) 
                 )
        )
      )
    )
  )
)