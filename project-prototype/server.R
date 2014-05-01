source("global.R")

shinyServer(function(input, output) {
  cat("Press \"ESC\" to exit...\n")
  
  output$bubbleplot <- renderPlot({
    print(plotBubble())
  })
  
  output$timeseries <- renderPlot({
    print(plotTime())
  })
  
  output$barchart <- renderPlot({
    print(plotBar())
  })
  
  output$map <- renderPlot({
    print(plotMap())
  })
  
})