require(ggplot2)
require(shiny)

require(reshape)
require(scales)

load_data <- function(var1, var2){
  data(Seatbelts)
  data <- transform(data.frame(Seatbelts), time = time(Seatbelts))
  
  series <- as.numeric(data$time)
  drivers <- as.numeric(data$drivers) 
  
  eval(parse(text = paste(var1, "<- as.numeric(data$", var1, ")", sep="")))
  eval(parse(text = paste(var2, "<- as.numeric(data$", var2, ")", sep="")))
  
  eval(parse(text = paste("seatdata <- data.frame(series, drivers, ", var1, ", ", var2, ")", sep="")))

  return(seatdata)
}

melt_data <- function(var1, var2, start, num){
  data(Seatbelts)
  data <- window(Seatbelts, start=c(start, 1), end=c(start+num-1, 12), frequency=12)
  data <- transform(data.frame(data), time = time(data))
  
  series <- data$time
  drivers <- as.numeric(data$drivers) 
  
  eval(parse(text = paste(var1, "<- as.numeric(data$", var1, ")", sep="")))
  eval(parse(text = paste(var2, "<- as.numeric(data$", var2, ")", sep="")))
  
  eval(parse(text = paste("seatdata <- data.frame(series=as.numeric(series), drivers, ", var1, ", ", var2, ")", sep="")))

  # extract years for grouping later
  years <- floor(series)
  years <- factor(years, ordered = TRUE)
  seatdata$year <- years
  
  # store month abbreviations as factor
  months <- factor(
    month.abb[cycle(series)],
    levels = month.abb,
    ordered = TRUE
  )
  seatdata$month <- months
  
  molten <- melt(
    seatdata,
    id = c("year", "month", "series")
  )  
  
  return(molten)
}

grey <- "#CCCCCC"
red <- "#D95F02"

plotOverview <- function(start = 1974, num = 1, var1="front", var2="rear", type="Multiple Lines") {
  seatdata <- load_data(var1, var2)
  series <- seatdata$series
  
  num <- num*12
  
  xmin <- start
  xmax <- start + (num / 12)
  
  ymin <- 1000
  ymax <- 2700
  
  p <- ggplot(seatdata, aes(x = series, y = drivers))
  
  p <- p + geom_rect(
    xmin = xmin, xmax = xmax,
    ymin = ymin, ymax = ymax,
    fill = grey)
  
  p <- p + geom_line(color=red)
  
  p <- p + scale_x_continuous(
    limits = range(series),
    expand = c(0, 0),
    breaks = seq(1969, 1984, by = 1))
  
  p <- p + scale_y_continuous(
    limits = c(ymin, ymax),
    expand = c(0, 0),
    breaks = seq(ymin, ymax, length.out = 3))
  
  p <- p + theme(panel.border = element_rect(
    fill = NA, colour = grey))
  
  p <- p + theme(axis.title = element_blank())
  p <- p + theme(panel.grid = element_blank())
  p <- p + theme(panel.background = element_blank())
  
  return(p)
}

plotArea <- function(start = 1969, num = 1, var1="front", var2="rear", type="Multiple Lines") {
  
  #start = 1969
  #num=1
  #var1="front"
  #var2="rear"
  
  seatdata <- load_data(var1, var2)
  
  if (type=="Multiple Lines"){
    seatmelt <- melt(seatdata, id = "series")
    
    num <- num*12
    
    xmin <- start
    xmax <- start + (num / 12)
    
    p <- ggplot(
      seatmelt,
      aes(x = series, y = value, 
          group = variable,
          color = variable))
    
    p <- p + theme_bw()
    
    p <- p + geom_line(size=1)
    
    p <- p + facet_grid(variable ~ ., scale = "free_y", labeller=label_value) +
      theme(strip.text.y = element_text(size = 12, angle=0),
            strip.background = element_rect(fill=NA, colour = grey))
    
    p <- p + scale_color_manual(values=c("#D95F02", "#7570B3", "#1B9E77"))
    
    minor_breaks <- seq(
      floor(xmin), 
      ceiling(xmax), 
      by = 1/ 12)
    
    p <- p + scale_x_continuous(
      limits = c(xmin, xmax),
      expand = c(0, 0),
      oob = rescale_none,
      breaks = seq(floor(xmin), ceiling(xmax), by = 1),
      minor_breaks = minor_breaks)
    
    p <- p + theme(axis.title = element_blank())
    
    p <- p + theme(legend.position="none")
    
    p <- p + theme(panel.border = element_rect(
      fill = NA, colour = grey))
  } else {
    molten <- melt_data(var1, var2, start, num)
    
    # CREATE BASE PLOT ####################
    molten <- ddply(molten, .(variable), transform, value = scale(value))
    
    # Labels and breaks need to be added with scale_y_discrete.
    y_labels = levels(molten$variable)
    y_breaks = seq_along(y_labels) + 15
    
    palette <- c("#008837", "#f7f7f7", "#7b3294")
    
    if (start+num<=1985){
      end <- start+num
    } else {
      end <- 1985
    }
    p <- ggplot(molten, aes(x=month, y=year, fill=value)) +
      geom_tile(colour="white") +
      scale_fill_gradient2(low = palette[1], mid = palette[2], high = palette[3]) + 
      scale_y_discrete(breaks=y_breaks, labels=y_labels) +
      coord_polar(theta="x") +
      theme(panel.background=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_text(size = 15, angle=0),
            panel.grid=element_blank(),
            axis.ticks=element_blank(),
            axis.text.y=element_text(size=5)) +
      ylab(c(paste("Year\n", start, " - ", end, sep="")))
    
    p <- p + facet_grid(. ~ variable, scale = "free_y") +
      theme(strip.text.x = element_text(size = 12, angle=0),
            strip.background = element_rect(fill=NA, colour = grey))
  }
  
  
  return(p)
}

# test_start = 1979.35
# print(plotOverview(start = test_start))
# print(plotArea(start = test_start))