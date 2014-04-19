require(ggplot2)
source("read.r")

# Sort bars by frequency
bar_df <- head(sotu_df, 10)
bar_df <- rbind(data.frame(word=bar_df$word, freq=bar_df$freq80, prop=bar_df$prop80,
                           year=rep("80s", 10)), 
                data.frame(word=bar_df$word, freq=bar_df$freq90, prop=bar_df$prop90,
                           year=rep("90s", 10)))
bar_df$word <- factor(bar_df$word, 
                      levels = bar_df$word, 
                      ordered = TRUE)

# Print a simple bar plot of the top 10 words
p <- ggplot(bar_df, aes(x = word, y = prop, group=year, fill=year)) +
  geom_bar(position='dodge',stat = "identity", width=.8) +
  ggtitle("State of Movie Titles in 80s and 90s") +
  xlab("Top 10 Word Stems (Stop Words Removed)") +
  ylab("Proportion (%)") +
  theme_minimal() +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  theme(panel.grid = element_blank()) +
  theme(axis.ticks = element_blank()) +
  scale_fill_manual(values=c("grey40", "light blue")) +
  theme(axis.text=element_text(family="serif", size=10),
        axis.title=element_text(family="serif", size=11),
        title=element_text(family="serif", size=15 ,face="bold")) +
  theme(legend.direction = "horizontal",
        legend.justification = c(1, 1),
        legend.position = c(1, 1))

print(p)

ggsave(
  filename = file.path("bar_plot.png"),
  width = 8,
  height = 5,
  dpi = 100
)