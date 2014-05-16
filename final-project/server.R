source("global.R")

shinyServer(function(input, output, session) {
  cat("Press \"ESC\" to exit...\n")
  
  observe({
    if (input$compare1 == "World"){
      updateRadioButtons(session, 
                         "color1", 
                         "Color by:",
                         c("World"),
                         selected = c("World"))
    } else if (input$compare1 == "Region"){
      updateRadioButtons(session, 
                           "color1", 
                           "Color by:",
                          c("Region"),
                          selected = c("Region"))
    } else if (input$compare1 == "Country"){
      updateRadioButtons(session, 
                           "color1", 
                           "Color by:",
                          c("Region", "Income Level"),
                          selected = c("Region"))
    }    
    
  })
  
  output$bubbleplot <- renderPlot({
    print(plotBubble(input$compare1, input$color1, input$yvar1, 
                     input$region, input$country, input$income, input$start, input$size))
  })
  
  output$timeseries <- renderPlot({
    print(plotTime(input$compare2, input$yvar2, 
                   input$region, input$country, input$income, 
                   input$year_range))
  })
  
  output$distribution <- renderPlot({
    print(plotDist(input$compare3, input$yvar3, 
                   input$region, input$country, input$income, 
                   input$start3))
  })
  
  output$map <- renderPlot({
    print(plotMap(input$yvar4, input$region, input$country, input$income, input$start4))
  })
  
})