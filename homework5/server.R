shinyServer(function(input, output) {
  output$mainPlot <- renderPlot({
    print(plotArea(input$start, input$num, input$var1, input$var2, input$type))
  })
  
  output$overviewPlot <- renderPlot({
    print(plotOverview(input$start, input$num, input$var1, input$var2))
  })
})