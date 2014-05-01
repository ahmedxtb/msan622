df <- read.csv("Life.Exp.Clean.csv", header = TRUE, sep = ",")


shinyUI(
  
  fluidPage(
    titlePanel("Life Expectancy in the World"),
    fluidRow( # Main Row 1
      column( width=3, # R1 C1 # Sider Bar
        fluidRow( # Row 1
            #div(class="span1"), # Col 1.0            
            
            column( width=6, # Col 1.1
                radioButtons(
                  "compare", 
                  "Compare by:",
                  c("World", "Region", "Country"),
                  selected = c("Country")
                ),
                
                radioButtons(
                  "color", 
                  "Color by:",
                  c("Region", "Income Level"),
                  selected = c("Region")
                )
            ), # End of Col 1.1
            
            column( width=6, # Col 1.2
                radioButtons(
                  "xvar", 
                  "X-Value:",
                  c("Life Expectancy"),
                  selected = c("Life Expectancy")
                ),
                
                radioButtons(
                  "yvar", 
                  "Y-Value:",
                  c("Fertility Rate", "Birth Rate", "Death Rate", "Life Expectancy"),
                  selected = c("Fertility Rate")
                )
            ) # End of Col 1.2
            
        ), # End of Row 1
        
        fluidRow( # Row 2
            # div(class="span1"), # Col 2.0
            column( width=12, # Col 2.1
                "Filter by:",
                
                selectInput(
                  'region',
                  '- Region: ',
                  unique(df$Region),
                  multiple=T
                ),
                
                selectInput(
                  'country',
                  '- Country: ',
                  unique(df$Country.Name),
                  multiple=T
                ),
                
                selectInput(
                  'income',
                  '- Income Level: ',
                  unique(df$IncomeGroup),
                  multiple=T
                )
                
            ) # End of Col 2.1
            
        ), # End of Row 2
        "Selected Variables:", br(),
        "- Country: Country, WB",br(),
        "- Region: World Region, WB",br(),
        "- Life Expentancy: The average number of years a newborn is expected to live with current mortality patterns remaining the same.",br(),
        "- Fertility Rate: The average number of births per woman.",br()
      ), # End of R1 C1 # Sider Bar
      column( width=9, # R1 C2 # Main Panel
              
              tabsetPanel(
                tabPanel("Bubble Plot",
                         
                         fluidPage(
                           fluidRow(
                             plotOutput("bubbleplot")
                            ),
                           fluidRow(
                             column( width=9,
                                     sliderInput(
                                       "start", 
                                       NULL,
                                       min = 1960, 
                                       max = 2012,
                                       value = 2012, 
                                       step = 1,
                                       format = "####",
                                       animate = animationOptions(
                                         interval = 1000, 
                                         loop = F
                                       )
                                     )
                               ),
                             column( width=1),
                             column( width=2,
                                     sliderInput(
                                       "size",
                                       "Bubble size:",
                                       min = 5,
                                       max = 50,
                                       step = 1,
                                       value = 30
                                       ),
                                     "Proportional to population"
                             )
                           )
                         )
                ),
                tabPanel("Time Series" ,
                         fluidPage(
                           fluidRow(
                             column( width=10,
                                     plotOutput("timeseries") 
                              ), 
                             column( width=2)
                           ),
                           fluidRow(
                             column( width=10,
                                     sliderInput(
                                       "year_range", 
                                       NULL,
                                       min = 1960, 
                                       max = 2012,
                                       value = c(1960,2012), 
                                       step = 1,
                                       format = "####"
                                     ),
                                     br(), br()
                             ),
                             column( width=2)                        
                           )
                         )
                ),
                tabPanel("Bar Chart" ,
                         fluidPage(
                           fluidRow(
                             plotOutput("barchart")
                           ),
                           fluidRow(
                             column( width=9,
                                     sliderInput(
                                       "start", 
                                       NULL,
                                       min = 1960, 
                                       max = 2012,
                                       value = 2012, 
                                       step = 1,
                                       format = "####",
                                       animate = animationOptions(
                                         interval = 1000, 
                                         loop = F
                                       )
                                     )
                             ),
                             column( width=1),
                             column( width=2,
                                     radioButtons(
                                       "sort",
                                       "Sort:",
                                       c("Descending", "Ascending", "Original"),
                                       selected = c("Descending")
                                     )
                             )
                           )
                         )
                ),
                tabPanel("Map" ,
                         fluidPage(
                           fluidRow(
                             column(width = 11,
                                    plotOutput("map")
                                  ),
                             column(width = 1)
                           ),
                           fluidRow(
                             column( width=9,
                                     sliderInput(
                                       "start", 
                                       NULL,
                                       min = 1960, 
                                       max = 2012,
                                       value = 2012, 
                                       step = 1,
                                       format = "####",
                                       animate = animationOptions(
                                         interval = 1000, 
                                         loop = F
                                       )
                                     ),
                                     br()
                             ),
                             column( width=3)
                           )
                         )
                         
                )
              ),
              "* Data source: World Bank", br(),
              "* Reference: Google Public Data Explorer"
      ) # End of R1 C2 # Main Panel
      
    ) # End of Main Row 1
  ) # End of Page  
  
)