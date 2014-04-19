require(ggplot2)
source("read.r")

# Create a data frame comparing 80s and 90s
freq_df <- head(sotu_df, 10)

# Plot frequencies
p <- ggplot(freq_df, aes(prop80, prop90))
p <- p + geom_point(size=5, color="light blue")
p <- p + geom_text(
  aes(label = word), color = "grey40", size=4,
  hjust = -0.2, vjust = 0.3, fontface=4)

p <- p + xlab("Proportion in 80s (%)") + ylab("Proportion in 90s (%)")
p <- p + ggtitle("State of Movie Titles in 80s and 90s")
p <- p + scale_x_continuous(expand = c(0, 0))
p <- p + scale_y_continuous(expand = c(0, 0))
p <- p + coord_fixed(xlim = c(0.1, 0.6), ylim = c(0.1, 0.6))
p <- p + theme_minimal()
p <- p + theme(axis.ticks = element_blank())
p <- p + theme(axis.text=element_text(family="serif", size=10),
               axis.title=element_text(family="serif", size=11),
               title=element_text(family="serif", size=15 ,face="bold"))

print(p)

ggsave(
  filename = file.path("freq_plot.png"),
  width = 8,
  height = 5,
  dpi = 100
)