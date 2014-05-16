require(ggplot2)
require(shiny)

#require(reshape)
require(scales)
require(grid)

gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}

brush_color = "#EEEEEE"
world_color = "blue"
data <- read.csv("Life.Exp.Clean.csv", header = TRUE, sep = ",")

load_data <- function(region, country, income, year){
  df <- data
  if(length(region)!=0){
    df <- df[which(df$Region%in%region),]
  }
  if(length(country)!=0){
    df <- df[which(df$Country.Name%in%country),]
  }
  if(length(income)!=0){
    df <- df[which(df$IncomeGroup%in%income),]
  }
  # filter by year
  if (length(year)==1){
    df <- df[which(df$year==year),]
  }else if (length(year)==2){
    df <- df[which(df$year>=year[1]&df$year<=year[2]),]
  }  
  
  return(df)
}

load_data_map <- function(region, country, income, start, yvar){
  df <- data[which(data$year==start),]
  idx <- NULL
  if(length(region)!=0){
    idx <- c(idx, which(df$Region%in%region))
  }
  if(length(country)!=0){
    idx <- c(idx, which(df$Country.Name%in%country))
  }
  if(length(income)!=0){
    idx <- c(idx, which(df$IncomeGroup%in%income))
  }
  idx <- unique(idx)
  
  if (length(idx>0)){
    eval(parse(text = paste("df$", yvar, "[-idx]<-0", sep="")))
  }  
  
  return(df)
}

load_data_bubble <- function(region, country, income, start_year, color){
  df <- data
  
  # filter by year
  df <- df[which(df$year==start_year),]
  
  # color by which variable
  if(color=="World"){
    
    df$color <- world_color
    
  } else if(color=="Region"){
    
    Regions <- levels(df$Region)
    colors <- gg_color_hue(length(Regions))
    color_idx <- sapply(df$Region, function(x) which(Regions%in%x))
    df$color <- colors[color_idx]
    
  } else if(color=="Income Level"){
    
    Income <- levels(df$IncomeGroup)
    colors <- brewer_pal(type = "qual", palette = "Set2")(length(Income))
    color_idx <- sapply(df$IncomeGroup, function(x) which(Income%in%x))
    df$color <- colors[color_idx]
    
  }
  
  # brush
  idx <- which(df$Region%in%region)
  idx <- c(idx, which(df$Country.Name%in%country))
  idx <- c(idx, which(df$IncomeGroup%in%income))
  idx <- unique(idx)
  
  if (length(idx)!=0){
    df$color[-idx] <- brush_color
  }
  df$color <- as.factor(df$color)
  df$border.color <- as.factor(ifelse(df$color==brush_color, brush_color, 'black'))
  df <- df[order(df$border.color, -df$Population),]
  
  # legend label
  df_sub <- df[which(df$color!=brush_color), ]
  df_sub$color <- droplevels(df_sub$color)
  
  if(color=="World"){
    
    label <- "World"
    
  } else if(color=="Region"){
    
    df_sub$Region <- droplevels(df_sub$Region)
    label <- unique(df_sub[c("color", "Region")])
    label <- label$Region[match(levels(df$color), label$color)]
    
  } else if(color=="Income Level"){
    
    df_sub$IncomeGroup <- droplevels(df_sub$IncomeGroup)
    label <- unique(df_sub[c("color", "IncomeGroup")])
    label <- label$IncomeGroup[match(levels(df$color), label$color)]
    
  }
  label <- as.character(label)
  #label <- ifelse(is.na(label), NA, sprintf("%-40s", label))
  df$alpha <- 1
  
  return(list(df=df, label=label))
}

plotBubble <- function(compare, color, yvar, region, country, income, start_year, bubble_size){ 
  df <- load_data_bubble(region, country, income, start_year, color)
  label <- df$label
  df <- df$df
  
  yvar0 <- sub(" ", ".", yvar)
  
  if (compare=="World"){
    eval(parse(text = paste("tmp1 <- mean(df$", yvar0, ")", sep="")))
    tmp2 <- mean(df$Life.Exp)
    tmp3 <- sum(df$Population)
    eval(parse(text = paste("df <- data.frame(", yvar0, "=tmp1, Life.Exp=tmp2, Population=tmp3, 
                            color='", world_color, "', border.color='black')", sep="")))
  } else if (compare=="Region"){
    #tmp1 <- aggregate(Fertility.Rate~color+border.color, data=df, mean)
    eval(parse(text = paste("tmp1 <- aggregate(", yvar0, "~Region, data=df, mean)", sep="")))
    tmp2 <- aggregate(Life.Exp~Region, data=df, mean)
    tmp3 <- aggregate(Population~Region, data=df, sum)
    tmp4 <- unique(df[c("Region", "color", "border.color")])
    df <- merge(tmp1, tmp2, by=c("Region"))
    df <- merge(df, tmp3, by=c("Region"))
    df <- merge(df, tmp4, by=c("Region"))
    df <- df[order(df$border.color, -df$Population),]
  }
  
  
  if (yvar=="Fertility Rate"){
    ylims <- c(0, 10)
  } else {
    ylims <- c(0, 60)
  }
  xlims <- c(15, 85)
  
  # Basic
  eval(parse(text = paste("p <- ggplot(df, aes(
                            x = Life.Exp, 
                            y = ", yvar0, 
                           "))", sep="")))
  
  
  p <- p + theme_bw()
  
  # Bubbles
  p <- p + geom_point(aes(fill = color, size = Population, color=border.color),
                      shape = 21, alpha = 1)
  
  p <- p + scale_size_area(max_size = bubble_size, guide = "none")  
  
  p <- p + scale_fill_manual(values = levels(df$color), 
                             breaks=levels(df$color)[which(levels(df$color)!=brush_color)], 
                             labels=label[which(!is.na(label))],
                             name=color)
  p <- p + scale_color_manual(values= levels(df$border.color), guide=FALSE)
  
  # Legend
  p <- p + theme(legend.margin = unit(1, "cm"))
  p <- p + theme(legend.key = element_blank())
  #p <- p + theme(legend.key.width = unit(1, "cm"))
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
    y = yvar)  
  
  # Background
  p <- p + theme(panel.background = element_rect(fill = NA))
  p <- p + theme(panel.grid.major = element_line(color = "grey90"))
  p <- p + theme(panel.grid.minor = element_line(color = "grey90", linetype = 4))   
                             
  return(p)                        
}

plotTime <- function(compare, yvar, region, country, income, year_range){ 
  #region=NULL; country=NULL; income=NULL; year_range=c(1960, 2012)
  df <- load_data(region, country, income, year_range)
  
  if (yvar=="Life Expectancy"){
    yvar0 <- "Life.Exp"
  } else {
    yvar0 <- sub(" ", ".", yvar)
  }
  
  if (compare=="World"){
    #df <- aggregate(Fertility.Rate~year, data=df, mean)
    eval(parse(text = paste("df <- aggregate(", yvar0, "~year, data=df, mean)", sep="")))
    
  } else {
    if (compare=="Region"){
      compare0 <- "Region"
    } else if (compare=="Income Level"){
      compare0 <- "IncomeGroup"
    } else if (compare=="Country"){
      compare0 <- "Country.Name"
    }
    eval(parse(text = paste("df <- aggregate(", yvar0, "~year+", compare0,", data=df, mean)", sep="")))
  }  
  
  xlims <- year_range  
  if (yvar=="Life Expectancy"){
    ylims <- c(0, ceiling(max(df[c(yvar0)]))+5)
  } else {
    ylims <- c(0, ceiling(max(df[c(yvar0)])))
  }  
  
  if (compare=="World"){
    
    eval(parse(text = paste("p <- ggplot(df, aes(
                            x = year, 
                            y = ", yvar0, 
                            "))", sep="")))
  } else {
    eval(parse(text = paste("p <- ggplot(df, aes(
                            x = year, 
                            y = ", yvar0, ",", 
                            "group = ", compare0, "))", sep="")))
  }
  p <- p + theme_bw()
  
  if (compare=="World"){    
    p <- p + geom_line(size = 1, color = world_color)
    p <- p + annotate(
      "text", x = year_range[2], y = df[c(yvar0)][nrow(df),], vjust=-1, hjust=1,
      color = "blue", size = 5, fontface=4,
      label = "World")
  } else if (compare=="Region"){
    
    p <- p + geom_line(aes(color=Region), size = 1)
    colors <- gg_color_hue(length(levels(df$Region)))
    colors <- colors[match(unique(df$Region), levels(df$Region))]  
    p <- p + scale_color_manual(values= colors, name=compare)
    
  } else if (compare=="Income Level"){
    
    p <- p + geom_line(aes(color=IncomeGroup), size = 1)
    colors <- brewer_pal(type = "qual", palette = "Set2")((length(levels(df$IncomeGroup))))
    colors <- colors[match(unique(df$IncomeGroup), levels(df$IncomeGroup))]
    p <- p + scale_color_manual(values= colors, name=compare)
    
  } else if (compare=="Country"){
    if (length(country)==0|length(country)>8){
      p <- p + annotate(
        "text", x = xlims[1]+15, y = ylims[2]-10, 
        color = "blue", size = 8, 
        label = "Please select at most 8 countries")
    } else {
      p <- p + geom_line(aes(color=Country.Name), size = 1)
      colors <- brewer_pal(type = "qual", palette = "Dark2")((length(unique(df$Country.Name))))
      p <- p + scale_color_manual(values= colors, name=compare)
    }
  }  
  
  # Legend
  p <- p + theme(legend.margin = unit(1, "cm"))
  p <- p + theme(legend.key = element_blank())
  p <- p + theme(legend.text = element_text(size = 12)) 
  
  p <- p + labs(
    x = "Year",
    y = yvar) 
  
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

plotDist <- function(compare, yvar, region, country, income, start){
  #region=NULL; country=NULL; income=NULL; year_range=c(1960, 2012)
  if (compare=="World"){
    region=NULL; country=NULL; income=NULL
    
    if (yvar=="Fertility Rate"){
      ylims <- c(0, 0.5)
    } else if (yvar=="Death Rate"){
      ylims <- c(0, 0.2)
    } else {
      ylims <- c(0, 0.1)
    }
  } else {    
    country=NULL; income=NULL
    
    if (yvar=="Fertility Rate"){
      ylims <- c(0, 1.5)
    } else if (yvar=="Death Rate"){
      ylims <- c(0, 0.5)
    } else {
      ylims <- c(0, 0.2)
    }
  }
  df <- load_data(region, country, income, start)
  df <- df[order(df$Region),]
  
  if (yvar=="Life Expectancy"){
    yvar0 <- "Life.Exp"
  } else {
    yvar0 <- sub(" ", ".", yvar)
  }   
  
  # ylims <- c(0, 1)  
  if (yvar=="Life Expectancy"){
    xlims <- c(15, 90)
  } else if (yvar=="Fertility Rate") {
    xlims <- c(0, 10)
  } else {
    xlims <- c(0, 60)
  }
  
  eval(parse(text = paste("p <- ggplot(df, aes(
                          x = ", yvar0, 
                          "))", sep="")))
  
  p <- p + theme_bw()
  
  if (compare=="World"){    
    p <- p + geom_density(colour="dark blue", fill=world_color, alpha=0.3)
  } else if (compare=="Region"){
    if (length(region)==0|length(region)>3){
      p <- p + annotate(
        "text", x = xlims[1], y = 0.1, vjust=1, hjust=-1,
        color = "blue", size = 8, 
        label = "Please select at most 3 regions")
    } else if ("North America"%in%region){
      p <- p + annotate(
        "text", x = xlims[1], y = 0.1, vjust=1, hjust=-1,
        color = "blue", size = 8, 
        label = "North America has too less data. \nPlease select another region.")
    } else {
      p <- p + geom_density(aes(group=Region, colour=Region, fill=Region), alpha=0.3)
      colors <- gg_color_hue(length(levels(df$Region)))
      colors <- colors[match(unique(df$Region), levels(df$Region))]
      p <- p + scale_color_manual(values= colors, name=compare)  
      p <- p + scale_fill_manual(values= colors, name=compare)
    }
  }  
  
  # Legend
  p <- p + theme(legend.margin = unit(1, "cm"))
  p <- p + theme(legend.key = element_blank())
  p <- p + theme(legend.text = element_text(size = 12)) 
  
  p <- p + labs(
    x = yvar0,
    y = "Density") 
  
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

plotMap <- function(yvar, region, country, income, start){
  
  if (yvar=="Life Expectancy"){
    yvar0 <- "Life.Exp"
  } else {
    yvar0 <- sub(" ", ".", yvar)
  }
  
  #region=NULL; country=NULL; income=NULL; start=2012; yvar0="Life Expectancy"
  df <- load_data_map(region, country, income, start, yvar0)
  
  df$region <- as.character(df$Country.Name)
  df$region[df$region=="Antigua and Barbuda"] <- "Antigua"
  df$region[df$region=="Bahamas, The"] <- "Bahamas"
  df$region[df$region=="Brunei Darussalam"] <- "Brunei"
  df$region[df$region=="Congo, Dem. Rep."] <- "Congo"
  df$region[df$region=="Cabo Verde"] <- "Cape Verde"
  df$region[df$region=="Egypt, Arab Rep."] <- "Egypt"
  df$region[df$region=="Micronesia, Fed. Sts."] <- "Micronesia"
  df$region[df$region=="United Kingdom"] <- "UK"
  df$region[df$region=="Korea, Dem. Rep."] <-"North Korea"
  df$region[df$region=="Syrian Arab Republic"] <-"Syria"
  df$region[df$region=="Trinidad and Tobago"] <-"Trinidad"
  df$region[df$region=="United States"] <-"USA"
  df$region[df$region=="St. Vincent and the Grenadines"] <-"Saint Vincent"
  df$region[df$region=="Venezuela, RB"] <-"Venezuela"
  df$region[df$region=="Virgin Islands (U.S.)"] <-"Virgin Islands"
  df$region[df$region=="Yemen, Rep."] <-"Yemen"  
  
  countries <- map_data("world")
  choro <- merge(countries, df, sort = FALSE, by = "region")
  choro <- choro[order(choro$order), ]
  
  #p <- qplot(long, lat, data = choro, group = group, fill = Fertility.Rate, geom = "polygon")
  eval(parse(text = paste("p <- qplot(long, lat, data = choro, group = group, 
                            fill = ", yvar0, ", geom = 'polygon')", sep="")))
  #p <- p + borders("world")
  
  p <- p + theme_bw()
  
  p <- p + scale_fill_gradient2(low = brush_color, high = "dark blue")
  
  p <- p + theme(axis.text = element_blank(),
                 axis.title = element_blank())
  p <- p + theme(axis.ticks = element_blank(),
                 panel.grid.major = element_blank(),
                 panel.grid.minor = element_blank())
  p <- p + scale_x_continuous(expand = c(0, 0))  
  
  p <- p + scale_y_continuous(expand = c(0, 0))
  
  return(p)
  
}