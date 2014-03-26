library(ggplot2)
library(gridExtra)
data(movies) 
data(EuStockMarkets)

#################################################3
# Transformations

# Filter out any rows that have a budget value less than or equal to 0 in the movies dataset
movies <- movies[which(!movies$budget<=0),]

# Add a genre column to the movies dataset
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

# Transform the EuStockMarkets dataset to a time series
eu <- transform(data.frame(EuStockMarkets), time = time(EuStockMarkets))


#################################################3
# Visualizations

# Choose colors for movie genre 
# (the genre with more points has red color, the genre with less points has green color)
genre_count <- aggregate(x=movies$genre, by=list(genre), FUN="length")
names(genre_count) <- c("genre", "count")
genre_count <- genre_count[order(-genre_count$count) , ]
genre_count$color <- c(1:9)
movies <- merge(movies, genre_count, by="genre")
movies$genre <- factor(movies$genre, levels=genre_count$genre)

# Plot 1: Scatterplot
scatterplot <- ggplot(movies, aes(x = budget/1000000, y = rating, color=as.factor(color))) + 
  geom_point() +
  ggtitle("Movie ratings versus budget") +
  xlab("Budget (Million Dollars)") + 
  ylab("Rating") +
  theme(axis.text=element_text(family="serif", size=10),
        axis.title=element_text(family="serif", size=12),
        title=element_text(family="serif", size=16,face="bold")) +
  scale_colour_brewer(palette="RdYlGn", labels=genre_count$genre, name="Genre")

print(scatterplot)
ggsave("hw1-scatter.png", dpi = 100, width = 7, height = 4)

# Plot 2: Bar Chart
barchart <- ggplot(genre_count, aes(x = reorder(genre, -count), y=count, fill=as.factor(color))) + 
  geom_bar(stat = "identity") + 
  ggtitle("Movie count by genres") + 
  xlab("Genre") + 
  ylab("Count") +
  theme(axis.text=element_text(family="serif", size=10),
        axis.title=element_text(family="serif", size=12),
        title=element_text(family="serif", size=16,face="bold")) +
  scale_fill_brewer(palette="RdYlGn") +
  theme(legend.position="none")

print(barchart)
ggsave("hw1-bar.png", dpi = 100, width = 7, height = 4)

# Plot 3: Small Multiples
multiples <- ggplot(movies, 
                    aes(x = budget/1000000, y = rating, group = genre, color=as.factor(color))) + 
  geom_point() +
  facet_wrap( ~ genre, ncol = 3) +
  ggtitle("Movie ratings versus budget") +
  xlab("Budget (Million Dollars)") + 
  ylab("Rating") +
  theme(axis.text=element_text(family="serif", size=10),
        axis.title=element_text(family="serif", size=12),
        title=element_text(family="serif", size=16,face="bold")) +
  scale_colour_brewer(palette="RdYlGn", labels=genre_count$genre, name="Genre")

print(multiples)
ggsave("hw1-multiples.png", dpi = 100, width = 7, height = 4)

# Plot 4: Multi-Line Chart
eu$new_time<-as.numeric(eu$time)
new_eu <- rbind(data.frame(price=eu$DAX, time=eu$new_time, index="DAX"),
                data.frame(price=eu$SMI, time=eu$new_time, index="SMI"),
                data.frame(price=eu$CAC, time=eu$new_time, index="CAC"),
                data.frame(price=eu$FTSE, time=eu$new_time, index="FTSE"))

multilines <- ggplot(new_eu,
                     aes(x = time, y = price,
                         group = factor(index),
                         color = factor(index))) + 
  geom_line() + 
  ggtitle("Price trend") + 
  xlab("Time") + 
  ylab("Price") +
  theme(axis.text=element_text(family="serif", size=10),
        axis.title=element_text(family="serif", size=12),
        title=element_text(family="serif", size=16, face="bold")) +
  labs(color="Index")

print(multilines)
ggsave("hw1-multiline.png", dpi = 100, width = 7, height = 4)
