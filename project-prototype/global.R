require(ggplot2)
require(shiny)

#require(reshape)
#require(scales)
require(grid)

gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}

load_data <- function(){
  df <- read.csv("Life.Exp.Clean.csv", header = TRUE, sep = ",")
  df <- df[which(df$Region!=""),]
  return(df)
}

plotBubble <- function(){ 
  df <- load_data()
  df <- df[which(df$year==2012),]
  df <- df[order(df$Population, decreasing=T),]
  
  xlims <- c(15, 85)
  ylims <- c(0, 10)
  
  # Basic
  p <- ggplot(df, aes(
    x = Life.Exp,
    y = Fertility.Rate
  ))   
  p <- p + theme_bw()
  
  # Bubbles
  p <- p + geom_point(aes(fill = Region, size = Population), color="black",
                      shape = 21, alpha=1)
  
  p <- p + scale_size_area(max_size = 30, guide = "none")
  
  p <- p + scale_fill_manual(values = gg_color_hue(length(unique(df$Region))))
  p <- p + scale_color_manual(guide=FALSE)
  
  # Legend
  #p <- p + theme(legend.title = element_blank())
  #p <- p + theme(legend.position = c(-1, 1))
  #p <- p + theme(legend.justification = c(-1, 1))
  #p <- p + theme(legend.background = element_rect(color="black", fill=NA, linetype=3))
  p <- p + theme(legend.margin = unit(1, "cm"))
  p <- p + theme(legend.key = element_blank())
  p <- p + theme(legend.text = element_text(size = 12))  
  
  p <- p + theme(axis.text = element_text(size = 14))
  
  p <- p + guides(fill = guide_legend(override.aes = list(size = 3)))
  
  # Axis
  p <- p + scale_x_continuous(
    limits = xlims,
    expand = c(0, 0))  
  
  p <- p + scale_y_continuous(
    limits = ylims,
    expand = c(0, 0))
  
  p <- p + labs(
    size = "Population",
    x = "Life Expectancy",
    y = "Fertility Rate")  
  
  # Background
  p <- p + theme(panel.background = element_rect(fill = NA))
  p <- p + theme(panel.grid.major = element_line(color = "grey90"))
  p <- p + theme(panel.grid.minor = element_line(color = "grey90", linetype = 4))
                             
  return(p)                        
}

plotTime <- function(){ 
  df <- load_data()
  df <- aggregate(Fertility.Rate~year, data=df, mean)
  
  xlims <- c(1960, 2012)
  ylims <- c(0, ceiling(max(df$Fertility.Rate)))
  
  p <- ggplot(df, aes(
    x = year,
    y = Fertility.Rate
  ))  
  p <- p + theme_bw()
  
  p <- p + geom_line(size = 1, color = "blue")
  
  p <- p + annotate(
    "text", x = 2012, y = df$Fertility.Rate[nrow(df)], vjust=-1, hjust=1,
    color = "blue", size = 5, fontface=4,
    label = "World")
  
  # Legend
  #p <- p + theme(legend.title = element_blank())
  #p <- p + theme(legend.position = c(-1, 1))
  #p <- p + theme(legend.justification = c(-1, 1))
  #p <- p + theme(legend.background = element_rect(color="black", fill=NA, linetype=3))
  p <- p + theme(legend.margin = unit(1, "cm"))
  p <- p + theme(legend.key = element_blank())
  p <- p + theme(legend.text = element_text(size = 12)) 
  
  p <- p + labs(
    x = "Year",
    y = "Fertility Rate") 
  
  p <- p + scale_x_continuous(
    limits = xlims,
    expand = c(0, 0),
    breaks = seq(xlims[1], xlims[2], by = 5),
    minor_breaks = seq(xlims[1], xlims[2], by = 1))
  
  p <- p + scale_y_continuous(
    limits = ylims,
    expand = c(0, 0))
  
  # Background
  p <- p + theme(panel.background = element_rect(fill = NA))
  p <- p + theme(panel.grid.major = element_line(color = "grey90"))
  p <- p + theme(panel.grid.minor = element_line(color = "grey90", linetype = 4))
  
  return(p)
}

plotBar <- function(){
  df <- load_data()
  df <- df[which(df$year==2012),]
  #df <- aggregate(Fertility.Rate~Region, data=df, mean)
  df <- df[order(df$Fertility.Rate, decreasing=T),]
  df$Country.Name <- factor(df$Country.Name, 
                      levels = df$Country.Name, 
                      ordered = TRUE)
  
  #xlims <- c(1960, 2010)
  ylims <- c(0, ceiling(max(df$Fertility.Rate)))
  
  # Basic
  p <- ggplot(df, aes(
    x = Country.Name,
    y = Fertility.Rate
  ))   
  p <- p + theme_bw()
  
  # Bars
  p <- p + geom_bar(stat = "identity", aes(fill = Region), color="black")
  
  p <- p + scale_fill_manual(values = gg_color_hue(length(unique(df$Region))))
  p <- p + scale_color_manual(guide=FALSE)
  # Legend
  # p <- p + theme(legend.position="none")
  p <- p + theme(legend.text = element_text(size = 12))   
  
  p <- p + theme(axis.text = element_text(size = 14))
  p <- p + theme(axis.text.x = element_blank())
  p <- p + theme(axis.ticks.x = element_blank(),
                 panel.grid.major.x = element_blank(),
                 panel.grid.minor.y = element_blank())
  
  #p <- p + guides(fill = guide_legend(override.aes = list(size = 3)))
  
  # Axis
  #p <- p + scale_x_continuous(
  #  limits = xlims,
  #  expand = c(0, 0))  
  
  p <- p + scale_y_continuous(
    limits = ylims,
    expand = c(0, 0))
  
  p <- p + labs(
    x = "Country",
    y = "Fertility Rate")  
  
  # Background
  p <- p + theme(panel.background = element_rect(fill = NA))
  p <- p + theme(panel.grid.major = element_line(color = "grey90"))
  p <- p + theme(panel.grid.minor = element_line(color = "grey90", linetype = 4))
  
  return(p)                        
}

plotMap <- function(){
  df <- load_data()
  df <- df[which(df$year==2012),]
  df$region <- df$Country.Name
  countries <- map_data("world")
  choro <- merge(countries, df, sort = FALSE, by = "region")
  choro <- choro[order(choro$order), ]
  p <- qplot(long, lat, data = choro, group = group, fill = Fertility.Rate,
        geom = "polygon")
  p <- p + theme_bw()
  p <- p + theme(axis.text = element_blank(),
                 axis.title = element_blank())
  p <- p + theme(axis.ticks = element_blank(),
                 panel.grid.major = element_blank(),
                 panel.grid.minor = element_blank())
  p <- p + scale_x_continuous(expand = c(0, 0))  
  
  p <- p + scale_y_continuous(expand = c(0, 0))
  
  return(p)
  
}