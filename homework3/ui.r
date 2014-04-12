library(shiny)

shinyUI(
  pageWithSidebar(
    headerPanel("GAPMINDER WORLD 1970s"),
    
    sidebarPanel(
      position = "left",
      
      wellPanel(
        div(class="row",
            div(class="span1"),
            div(class="span5",
                radioButtons(
                  "method", 
                  "Form:",
                  c("Brush", "Filter", "Zoom"),
                  selected = c("Brush")
                )),
            div(class="span6",
                checkboxGroupInput(
                  "region", 
                  "Region:",
                  c("North Central", "South", "West", "Northeast")
                ))
            ),
        div(class="row",
            div(class="span1"),
            div(class="span11",
                sliderInput(
                  "population", 
                  "Population:", 
                  min=300, max=21300, value = c(300,21300)),
                
                sliderInput(
                  "income",
                  "Income per Person:", 
                  min=3000, max=6500, value = c(3000,6500)),   
                
                sliderInput(
                  "expect",
                  "Life Expectancy in years:", 
                  min=67, max=74, value = c(67,74))
                )  
            )
                 
        
      ), 
      
      width = 3
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Bubble Plot", 
                 plotOutput("bubbleplot")
                 ),
        tabPanel("Scatterplot Matrix", 
                 plotOutput("scatterplots")
                 ),
        tabPanel("Parallel Coordinates Plot", 
                 plotOutput("parallel")
                 )
        )
      )
  )
)