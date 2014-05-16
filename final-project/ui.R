df <- read.csv("Life.Exp.Clean.csv", header = TRUE, sep = ",")

shinyUI(
  
  fluidPage(
    titlePanel("Life Expectancy in the World"),
    fluidRow( # Main Row 1
      column( width=3, # R1 C1 # Sider Bar
              conditionalPanel(condition="input.conditionedPanels==1", # Conditional Panel 1
                               fluidRow( # Row 1
                                 column( width=6, # Col 1.1
                                         radioButtons(
                                           "compare1", 
                                           "Compare by:",
                                           c("World", "Region", "Country"),
                                           selected = c("Country")
                                         ),
                                         
                                         radioButtons(
                                           "color1", 
                                           "Color by:",
                                           c("Region", "Income Level"),
                                           selected = c("Region")
                                         )
                                 ), # End of Col 1.1
                                 
                                 column( width=6, # Col 1.2
                                         radioButtons(
                                           "yvar1", 
                                           "Y-Value:",
                                           c("Fertility Rate", "Birth Rate", "Death Rate"),
                                           selected = c("Fertility Rate")
                                         )
                                 ) # End of Col 1.2
                                 
                               ) # End of Row 1
              ), # End of Conditional Panel 1
              conditionalPanel(condition="input.conditionedPanels==2", # Conditional Panel 2
                               fluidRow( # Row 1
                                 column( width=6, # Col 1.1
                                         radioButtons(
                                           "compare2", 
                                           "Compare by:",
                                           c("World", "Region", "Country", "Income Level"),
                                           selected = c("World")
                                         )
                                 ), # End of Col 1.1
                                 
                                 column( width=6, # Col 1.2	                
                                         radioButtons(
                                           "yvar2", 
                                           "Y-Value:",
                                           c("Life Expectancy", "Fertility Rate", "Birth Rate", "Death Rate"),
                                           selected = c("Life Expectancy")
                                         )
                                 ) # End of Col 1.2
                                 
                               ) # End of Row 1
              ),  # End of Conditional Panel 2
              conditionalPanel(condition="input.conditionedPanels==3", # Conditional Panel 3
                               fluidRow( # Row 1
                                 column( width=6, # Col 1.1
                                         radioButtons(
                                           "compare3", 
                                           "Compare by:",
                                           c("World", "Region"),
                                           selected = c("World")
                                         )
                                 ), # End of Col 1.1
                                 
                                 column( width=6, # Col 1.2                  
                                         radioButtons(
                                           "yvar3", 
                                           "X-Value:",
                                           c("Life Expectancy", "Fertility Rate", "Birth Rate", "Death Rate"),
                                           selected = c("Life Expectancy")
                                         )
                                 ) # End of Col 1.2
                                 
                               ) # End of Row 1
              ),  # End of Conditional Panel 3
              conditionalPanel(condition="input.conditionedPanels==4", # Conditional Panel 4
                               fluidRow( # Row 1
                                 column( width=6, # Col 1.1
                                         radioButtons(
                                           "yvar4", 
                                           "Y-Value:",
                                           c("Life Expectancy", "Fertility Rate", "Birth Rate", "Death Rate"),
                                           selected = c("Life Expectancy")
                                         )
                                 ) # End of Col 1.1
                                 
                                 
                               ) # End of Row 1
              ), # End of Conditional Panel 4
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
                        conditionalPanel(condition="input.conditionedPanels!=3", # Conditional Panel 4
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
                        )
                        
                ) # End of Col 2.1
                
              ), # End of Row 2
              "Variables:", br(),
              "- Life Expentancy: The average number of years a newborn is expected to live with current mortality patterns remaining the same.",br(),
              "- Fertility Rate: The average number of births per woman.",br(),
              "- Birth Rate: Birth rate, crude (per 1,000 people).",br(),
              "- Death Rate: Death rate, crude (per 1,000 people).",br()
              
      ), # End of R1 C1 # Sider Bar
      column( width=9, # R1 C2 # Main Panel
              
              tabsetPanel(
                tabPanel("Bubble Plot",
                         value=1,
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
                                         interval = 500, 
                                         loop = F
                                       )
                                     )
                             ),
                             column( width=1),
                             column( width=2,
                                     sliderInput(
                                       "size",
                                       "Bubble size:",
                                       min = 20,
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
                         value=2,
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
                tabPanel("Distribution" ,
                         value=3,
                         fluidPage(
                           fluidRow(
                             plotOutput("distribution")
                           ),
                           fluidRow(
                             column( width=9,
                                     sliderInput(
                                       "start3", 
                                       NULL,
                                       min = 1960, 
                                       max = 2012,
                                       value = 2012, 
                                       step = 1,
                                       format = "####",
                                       animate = animationOptions(
                                         interval = 500, 
                                         loop = F
                                       )
                                     )
                             ),
                             column( width=2)
                           )
                         )
                ),
                tabPanel("Map" ,
                         value=4,
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
                                       "start4", 
                                       NULL,
                                       min = 1960, 
                                       max = 2012,
                                       value = 2012, 
                                       step = 1,
                                       format = "####"
                                     ),
                                     br()
                             ),
                             column( width=3)
                           )
                         )
                         
                ),
                id = "conditionedPanels"
              ),
              "* Data source: World Bank", br(),
              "* Reference: Google Public Data Explorer"
      ) # End of R1 C2 # Main Panel
      
    ) # End of Main Row 1
  ) # End of Page  
  
)