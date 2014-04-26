shinyUI(pageWithSidebar(
  headerPanel("Road Casualties in Great Britain 1969-84"),
  
  sidebarPanel(
    radioButtons(
      "type", 
      NULL,
      c("Multiple Lines", "Circle Heat Map"),
      selected = c("Multiple Lines")
    ),
    
    selectInput(
      "var1",
      "Compared Variable 1:",
      c("front", "rear", "kms", "PetrolPrice", "VanKilled", "law"),
      selected = c("front")
    ), 
    
    selectInput(
      "var2",
      "Compared Variable 2:",
      c("front", "rear", "kms", "PetrolPrice", "VanKilled", "law"),
      selected = c("rear")
    ), 
    
    sliderInput(
      "num", 
      "Years:", 
      min = 1, 
      max = 16,
      value = 3, 
      step = 1
    ),
    
    sliderInput(
      "start", 
      "Start Year:",
      min = 1969, 
      max = 1984,
      value = 1969, 
      step = 1,
      format = "####",
      animate = animationOptions(
        interval = 3000, 
        loop = F
      )
    ),
    
    width = 3
  ),
  
  mainPanel(
    plotOutput(
      outputId = "mainPlot", 
      width = "100%", 
      height = "400px"
    ),
    
    plotOutput(
      outputId = "overviewPlot",
      width = "100%",
      height = "200px"
    ),
    
    width = 9
  )
))