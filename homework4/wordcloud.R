require(wordcloud) # word cloud
source("read.r")   # get data

# Create Wordcloud
# Can create directly from corpus too!

# png(
#     file.path("img", "sotu_cloud.png"),
#     width = 600,
#     height = 600)

cloud_df <- sotu_df
cloud_df$freq <- cloud_df$freq80+cloud_df$freq90
cloud_df <- cloud_df[order(-cloud_df$freq), ]
cloud_df <- head(cloud_df, 20)

wordcloud(
    cloud_df$word,
    cloud_df$freq,
    scale = c(6, 0.5),      # size of words
    min.freq = 10,          # drop infrequent
    max.words = 30,         # max words in plot
    random.order = FALSE,   # plot by frequency
    rot.per = 0.3,          # percent rotated
    # set colors
    # colors = brewer.pal(12, "Accent"),
    colors = c("light blue", "grey40"),
    # color random or by frequency
    random.color = TRUE,
    # use r or c++ layout
    # use.r.layout = FALSE,
    vfont=c("serif","bold")
  )
