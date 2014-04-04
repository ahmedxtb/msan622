library(ggplot2)
library(shiny)
library(scales)

data("movies")

loadData <- function() {

  # Filter out any rows that do not have a valid budget value greater than 0
  movies <- movies[which(!movies$budget<=0),]
  # Filter out any rows that do not have a valid MPAA rating in the mpaa column
  movies <- movies[which(!movies$mpaa==""),]
  
  genre <- rep(NA, nrow(movies))
  count <- rowSums(movies[, 18:24])
  genre[which(count > 1)] = "Mixed"
  genre[which(count < 1)] = "None"
  genre[which(count == 1 & movies$Action == 1)] = "Action"
  genre[which(count == 1 & movies$Animation == 1)] = "Animation"
  genre[which(count == 1 & movies$Comedy == 1)] = "Comedy"
  genre[which(count == 1 & movies$Drama == 1)] = "Drama"
  genre[which(count == 1 & movies$Documentary == 1)] = "Documentary"
  genre[which(count == 1 & movies$Romance == 1)] = "Romance"
  genre[which(count == 1 & movies$Short == 1)] = "Short"
  movies$genre <- as.factor(genre)
  movies$mpaa <- factor(movies$mpaa)
  
  return(movies)
}

getPlot <- function(df, highlight) {
  hl_mpaa <- highlight$hl_mpaa
  hl_genre <- highlight$hl_genre
  hl_color <- highlight$hl_color
  hl_alpha <- highlight$hl_alpha
  hl_size <- highlight$hl_size
  hl_type <- highlight$hl_type
  
  mpaa <- levels(df$mpaa) 
  is_mpaa_all <- F
  
  if (length(hl_genre) == 0) {
    hl_genre <- levels(df$genre)
    hl_alpha <- 0
  }
  
  if (hl_mpaa == "All") {
    hl_mpaa <- mpaa
    is_mpaa_all <- T
  }
  
  df <- df[which(df$genre %in% hl_genre),]
  p <- ggplot()
  
  if (!is_mpaa_all){
    if (nrow(df[which(!(df$mpaa %in% hl_mpaa)), ]) == 0){
      p <- p + geom_point(data=df, 
                          aes(x = budget/1000000, y = rating, color = mpaa),
                          size = hl_size, alpha = 0, position = "jitter")
    } else {
      p <- p + geom_point(data=df[which(!(df$mpaa %in% hl_mpaa)), ], 
                          aes(x = budget/1000000, y = rating, color = mpaa),
                          size = hl_size, alpha = hl_alpha, position = "jitter")      
    }    
  }  
  
  if (nrow(df[which(df$mpaa %in% hl_mpaa), ]) == 0){
    p <- p + geom_point(data=df, 
                        aes(x = budget/1000000, y = rating, color = mpaa),
                        size = hl_size, alpha = 0, position = "jitter")
  } else {
    p <- p + geom_point(data=df[which(df$mpaa %in% hl_mpaa), ], 
                        aes(x = budget/1000000, y = rating, color = mpaa),
                        size = hl_size, alpha = hl_alpha, position = "jitter") 
  }   
  
  if (hl_type == "Multiples"){
    p <- p + facet_wrap( ~ mpaa, ncol = 2)
  }
  
  p <- p + xlab("Budged in Millions")
  p <- p + ylab("Rating")
  p <- p + labs(color = "Movies MPAA")
  p <- p + theme(axis.text=element_text(size=12),
                 axis.title=element_text(size=12))
  
  p <- p + theme(panel.background = element_rect(fill = NA))
  p <- p + theme(legend.key = element_rect(fill = NA))
  p <- p + theme(panel.grid.major = element_line(color = "grey90"))
  p <- p + theme(panel.grid.minor = element_line(color = "grey90", linetype = 3))
  
  p <- p + scale_x_continuous(limit=c(-10,210), expand = c(0, 0))
  p <- p + scale_y_continuous(limit=c(0,11), expand = c(0, 0))
  p <- p + theme(panel.border = element_blank())
  
  if (hl_type == "Single"){    
    p <- p + theme(legend.direction = "horizontal")
    p <- p + theme(legend.justification = c(0, 0))
    p <- p + theme(legend.position = c(0, 0)) 
    p <- p + theme(legend.background = element_blank())
  } else {    
    p <- p + theme(legend.position="none")
  }
  
  gg_color_hue <- function(n) {
    hues = seq(15, 375, length=n+1)
    hcl(h=hues, l=65, c=100)[1:n]
  }  
  
  color_idx <- which(mpaa %in% unique(df$mpaa))
  if (hl_color == "Default"){
    palette <- gg_color_hue(4)[color_idx]
  } else {
    palette <- brewer_pal(type = "qual", palette = hl_color)(4)[color_idx]
  }
  
  palette[which(!(mpaa[color_idx] %in% hl_mpaa))] <- "#EEEEEE"
  p <- p + scale_color_manual(values = palette)     
  
  return(p)
}

shinyServer(function(input, output, session) {
  
  cat("Press \"ESC\" to exit...\n")
  
  localFrame <- loadData() 
  
  observe({
    if (input$isAll == "(Select All)"){
      updateCheckboxGroupInput(session, 
                               "genre", 
                               NULL,
                               c("Action", "Animation", "Comedy", "Drama", 
                                 "Documentary", "Romance", "Short"),
                               selected = c("Action", "Animation", "Comedy", "Drama", 
                                            "Documentary", "Romance", "Short"))
    } else if (input$isAll == "(Clear All)"){
      updateCheckboxGroupInput(session, 
                               "genre", 
                               NULL,
                               c("Action", "Animation", "Comedy", "Drama", 
                                 "Documentary", "Romance", "Short"))
    }
    
    
  })
  
  # Choose what having no species selected should mean.
  getHighlight <- reactive({
    return(list(hl_mpaa = input$mpaa, 
                hl_genre = input$genre,
                hl_color = input$color,
                hl_size = input$size,
                hl_alpha = input$alpha,
                hl_type = input$type))
  })
  
  output$scatterplot <- renderPlot({
    print(getPlot(localFrame,
                  getHighlight()))
  })
  
  output$trating <- renderTable(
  {
    hl_genre <- getHighlight()$hl_genre
    if (length(hl_genre)!=0){ 
      df <- localFrame[which(localFrame$genre %in% hl_genre),]
      trating <- tapply(df$rating, df$mpaa, summary)
      dfrating <- data.frame(matrix(unlist(trating, recursive = FALSE), nrow=6))
      srating <- cbind(Stat. = c("Min.", "1st.Qu.", "Median", "Mean", "3rd.Qu.", "Max."), dfrating)
      colnames(srating) <- c("Stat.", levels(df$mpaa)[sort(unique(df$mpaa))])
      return(srating)
    }
  },
  include.rownames = FALSE
  )
  
  output$tbudget <- renderTable(
  { 
    hl_genre <- getHighlight()$hl_genre
    if (length(hl_genre)!=0){ 
      df <- localFrame[which(localFrame$genre %in% hl_genre),]
      tbudget <- tapply(df$budget, df$mpaa, summary)
      dfbudget <- data.frame(matrix(unlist(tbudget, recursive = FALSE), nrow=6))/1000000
      sbudget <- cbind(Stat. = c("Min.", "1st.Qu.", "Median", "Mean", "3rd.Qu.", "Max."), 
                       dfbudget)
      colnames(sbudget) <- c("Stat.", levels(df$mpaa)[sort(unique(df$mpaa))])
      return(sbudget)
    }
  },
  include.rownames = FALSE
  )
  
})