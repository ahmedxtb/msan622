library(ggplot2)
library(shiny)
library(scales)
library(reshape2)
library(grid)
library(GGally)

gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}

gg_color_hue_border <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=50)[1:n]
}

loadData <- function() {

  df <- data.frame(state.x77,
                   State = state.name,
                   Abbrev = state.abb,
                   Region = state.region,
                   Division = state.division
  )
  
  Regions <- levels(df$Region)
  colors <- gg_color_hue(length(Regions))
  color_idx <- sapply(df$Region, function(x) which(Regions%in%x))
  df$color <- colors[color_idx]
  return(df)
}

getBubblePlot <- function(df, hightlight){
  
  hl_region <- hightlight$hl_region 
  hl_population <- hightlight$hl_population
  hl_income <- hightlight$hl_income
  hl_expect <- hightlight$hl_expect
  hl_method <- hightlight$hl_method
  
  if (length(hl_region) == 0){
    hl_region <- levels(df$Region)
  }
  
  if (hl_method == "Brush"){
    filtered_color <- "#EEEEEE"
  } else {
    filtered_color <- "#FFFFFF"
  }  
  
  xlims <- c(3000, 6500)
  ylims <- c(67, 74)
  if (hl_method == "Zoom"){
    xlims <- hl_income
    ylims <- hl_expect
  }
  
  # Data Set
  idx <- which(df$Population >= hl_population[1] & df$Population <= hl_population[2]
               & df$Income >= hl_income[1] & df$Income <= hl_income[2]
               & df$Life.Exp >= hl_expect[1] & df$Life.Exp <= hl_expect[2]
               & df$Region %in% hl_region)
  
  if (length(idx)==0){
    df$color <- filtered_color
  } else {    
    df$color[-idx] <- filtered_color
  }
  df$color <- as.factor(df$color)
  df$border.color <- as.factor(ifelse(df$color==filtered_color, filtered_color, 'black'))
  df <- df[order(df$border.color, -df$Population),]
  
  # Basic
  p <- ggplot(df, aes(
    x = Income,
    y = Life.Exp,
    label = Abbrev
    ))   
  p <- p + theme_bw()
  
  # Bubbles
  p <- p + geom_point(aes(fill = color, size = Population, color=border.color), 
                      shape = 21, alpha=1)
  
  p <- p + scale_size_area(max_size = 25, guide = "none")
  
  df_sub <- df[which(df$color!=filtered_color), ]
  df_sub$color <- droplevels(df_sub$color)
  df_sub$Region <- droplevels(df_sub$Region)
  label <- unique(df_sub[c("color", "Region")])
  label <- label$Region[match(levels(df$color), label$color)]
  p <- p + scale_fill_manual(values = levels(df$color), 
                             breaks=levels(df$color)[which(levels(df$color)!=filtered_color)], 
                             labels=label[which(!is.na(label))])
  p <- p + scale_color_manual(values= levels(df$border.color), guide=FALSE)
  
  # Legend
  p <- p + theme(legend.title = element_blank())
  p <- p + theme(legend.position = c(1, 1))
  p <- p + theme(legend.justification = c(1, 1))
  p <- p + theme(legend.background = element_rect(color="black", fill=NA, linetype=3))
  p <- p + theme(legend.margin = unit(1, "cm"))
  p <- p + theme(legend.key = element_blank())
  p <- p + theme(legend.text = element_text(size = 12))
  
  p <- p + guides(fill = guide_legend(override.aes = list(size = 4)))
  
  # Axis
  p <- p + scale_x_continuous(
    limits = xlims,
    expand = c(0, 0))  
  
  p <- p + scale_y_continuous(
    limits = ylims,
    expand = c(0, 0))
  
  p <- p + labs(
    size = "Population",
    x = "INCOME PER PERSON in US Dollars",
    y = "LIFE EXPECTANCY in years")  
  
  # Background
  p <- p + theme(panel.background = element_rect(fill = NA))
  p <- p + theme(panel.grid.major = element_line(color = "grey90"))
  p <- p + theme(panel.grid.minor = element_line(color = "grey90", linetype = 3))
  
}

getScatterMatrix <- function(df, hightlight){
  
  hl_region <- hightlight$hl_region 
  hl_population <- hightlight$hl_population
  hl_income <- hightlight$hl_income
  hl_expect <- hightlight$hl_expect
  hl_method <- hightlight$hl_method
  
  if (length(hl_region) == 0){
    hl_region <- levels(df$Region)
  }
  
  if (hl_method == "Brush"){
    filtered_color <- "#EEEEEE"
  } else {
    filtered_color <- "#FFFFFF"
  }
  
  # Data Set
  idx <- which(df$Population >= hl_population[1] & df$Population <= hl_population[2]
               & df$Income >= hl_income[1] & df$Income <= hl_income[2]
               & df$Life.Exp >= hl_expect[1] & df$Life.Exp <= hl_expect[2]
               & df$Region %in% hl_region)
  
  if (length(idx)==0){
    p <- NULL
  } else {   
    df$color[-idx] <- filtered_color
    if (hl_method=="Zoom"){
      df <- df[idx,]
    } else {      
      df <- rbind(df[-idx,], df[idx,])
    }
    df$color <- as.factor(df$color)
    
    df_sub <- df[c("Population", "Income", "Life.Exp", "Region", "color")]
    
    p <- ggpairs(df_sub, 
                 # Columns to include in the matrix
                 columns = 1:3,
                 
                 # "blank" to turn off
                 upper = "blank",
                 
                 # What to include below diagonal
                 lower = list(continuous = "points", size = 5),
                 
                 # What to include in the diagonal
                 diag = list(continuous = "density", size = 5),
                 
                 # How to label inner plots
                 # internal, none, show
                 axisLabels = 'none',
                 
                 # Other aes() parameters
                 colour = "color",
                 
                 legends = T
    )
    
    lims <- list(c(300, 21300), c(3000, 6500), c(67, 74))
    if (hl_method=="Zoom"){
      lims <- list(hl_population, hl_income, hl_expect)
    }
    
    # Remove grid from plots along diagonal
    for (i in 1:3) {
      for (j in 1:i){      
        # Get plot out of matrix
        inner = getPlot(p, i, j);
        
        # Add any ggplot2 settings you want
        label <- unique(df_sub[c("color", "Region")][which(df$color!=filtered_color), ])
        label <- label$Region[match(levels(df_sub$color), label$color)]
        inner <- inner + scale_color_manual(values= levels(df_sub$color), 
                                            breaks=levels(df_sub$color)[which(levels(df_sub$color)!=filtered_color)],
                                            labels=label[which(!is.na(label))])
        
        inner <- inner + xlim(lims[j][[1]])
        inner <- inner + ylim(lims[i][[1]])
        
        if (i==3 & j==1){        
          inner <- inner + theme(legend.title = element_blank())
          inner <- inner + theme(legend.position = c(3, 3))
          inner <- inner + theme(legend.justification = c(1, 1))
          inner <- inner + theme(legend.background = element_rect(color="black", fill=NA, linetype=3))
          inner <- inner + theme(legend.key = element_blank())
          inner <- inner + theme(legend.text = element_text(size = 12))
        } else {
          inner <- inner + theme(legend.position="none")
        }
        
        inner <- inner + theme(panel.background = element_rect(fill = NA))
        inner <- inner + theme(panel.grid.major = element_line(color = "grey90"))
        inner <- inner + theme(panel.grid.minor = element_line(color = "grey90", linetype = 3))
        
        # Put it back into the matrix
        p <- putPlot(p, inner, i, j);
      }
    }
  }
  
  return(p)
}

getParllel <- function(df, hightlight){
  
  hl_region <- hightlight$hl_region 
  hl_population <- hightlight$hl_population
  hl_income <- hightlight$hl_income
  hl_expect <- hightlight$hl_expect
  hl_method <- hightlight$hl_method
  
  if (length(hl_region) == 0){
    hl_region <- levels(df$Region)
  }
  
  if (hl_method == "Brush"){
    filtered_color <- "#EEEEEE"
  } else {
    filtered_color <- "#FFFFFF"
  }
  
  # Data Set
  idx <- which(df$Population >= hl_population[1] & df$Population <= hl_population[2]
               & df$Income >= hl_income[1] & df$Income <= hl_income[2]
               & df$Life.Exp >= hl_expect[1] & df$Life.Exp <= hl_expect[2]
               & df$Region %in% hl_region)
  
  if (length(idx)==0 | (length(idx)==1 & hl_method=="Zoom")){
    p <- NULL
  } else {  
    df$color[-idx] <- filtered_color
    if (hl_method=="Zoom"){
      if (length(idx)!=0){
        df <- df[idx, ]
      }    
    } else {
      df <- rbind(df[-idx,], df[idx,])
    }  
    df$color <- as.factor(df$color)
    df_sub <- df[c("Population", "Income", "Life.Exp", "Region", "color")]
    
    p <- ggparcoord(data = df_sub, 
                    
                    # Which columns to use in the plot
                    columns = 1:3, 
                    
                    # Which column to use for coloring data
                    groupColumn = 5, 
                    
                    # Allows order of vertical bars to be modified
                    order = 1:3,
                    
                    # Do not show points
                    showPoints = F,
                    
                    # Turn on alpha blending for dense plots
                    alphaLines = 0.6,
                    
                    # Turn off box shading range
                    shadeBox = NULL,
                    
                    # Will normalize each column's values to [0, 1]
                    scale = "uniminmax" # try "std" also
    )
    
    # Start with a basic theme
    p <- p + theme_minimal()
    
    # Decrease amount of margin around x, y values
    p <- p + scale_y_continuous(expand = c(0.02, 0.02))
    p <- p + scale_x_discrete(expand = c(0.02, 0.02))
    
    # Remove axis ticks and labels
    p <- p + theme(axis.ticks = element_blank())
    p <- p + theme(axis.title = element_blank())
    p <- p + theme(axis.text.y = element_blank())
    
    # Adjust legend
    p <- p + theme(legend.title = element_blank())
    p <- p + theme(legend.background = element_rect(color="black", fill=NA, linetype=3))
    p <- p + theme(legend.text = element_text(size = 12))
    p <- p + theme(legend.position = "bottom")
    
    # Clear axis lines
    p <- p + theme(panel.grid.minor = element_blank())
    p <- p + theme(panel.grid.major.y = element_blank())
    
    # Darken vertical lines
    p <- p + theme(panel.grid.major.x = element_line(color = "#bbbbbb"))
    
    # Change colors and labels of legend
    label <- unique(df_sub[c("color", "Region")][which(df_sub$color!=filtered_color), ])
    label <- label$Region[match(levels(df_sub$color), label$color)]
    p <- p + scale_color_manual(values= levels(df_sub$color), 
                                breaks=levels(df_sub$color)[which(levels(df_sub$color)!=filtered_color)],
                                labels=label[which(!is.na(label))])
    
    # Figure out y-axis range after GGally scales the data
    min_y <- min(p$data$value)
    max_y <- max(p$data$value)
    if (nrow(df)==1){
      pad_y <- max_y * 0.1
    } else {
      pad_y <- (max_y - min_y) * 0.1      
    }
    
    # Calculate label positions for each veritcal bar
    lab_x <- rep(1:3, times = 2) # 2 times, 1 for min 1 for max
    lab_y <- rep(c(min_y - pad_y, max_y + pad_y), each = 3)
    
    # Get min and max values from original dataset
    lab_z <- c(sapply(df_sub[, 1:3], min), sapply(df_sub[, 1:3], max))
    
    # Convert to character for use as labels
    lab_z <- as.character(lab_z)
    
    # Add labels to plot
    p <- p + annotate("text", x = lab_x, y = lab_y, label = lab_z, size = 3)
  } 
  
  return(p)
}

shinyServer(function(input, output, session) {
  
  cat("Press \"ESC\" to exit...\n")
  
  localFrame <- loadData() 
  
  getHighlight <- reactive({
    return(list(hl_region = input$region, 
                hl_population = input$population,
                hl_income = input$income,
                hl_expect = input$expect,
                hl_method = input$method))
  })
  
  output$bubbleplot <- renderPlot({
    print(getBubblePlot(localFrame,
                        getHighlight()))
  })
  
  output$scatterplots <- renderPlot({
    print(getScatterMatrix(localFrame,
                  getHighlight()))
  })
  
  output$parallel <- renderPlot({
    print(getParllel(localFrame,
                  getHighlight()))
  })
  
})