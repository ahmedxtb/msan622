require(tm)        # corpus
require(SnowballC) # stemming
require(ggplot2)

#data("movies")
#titles80 <- movies[movies$year < 1990 & movies$year >= 1980, ]$title
#titles90 <- movies[movies$year < 2000 & movies$year >= 1990, ]$title

#fileConn<-file("D:/ww_courses/Data Virsualization/HW4/1980/movie_titles_1980.txt")
#writeLines(titles80, fileConn)
#close(fileConn)

#fileConn<-file("D:/ww_courses/Data Virsualization/HW4/1990/movie_titles_1990.txt")
#writeLines(titles90, fileConn)
#close(fileConn)

words_frequency <- function(my_path){
  sotu_source <- DirSource(
    # indicate directory
    directory = file.path(my_path),
    encoding = "UTF-8",     # encoding
    pattern = "*.txt",      # filename pattern
    recursive = FALSE,      # visit subdirectories?
    ignore.case = FALSE)    # ignore case in pattern?
  
  sotu_corpus <- Corpus(
    sotu_source, 
    readerControl = list(
      reader = readPlain, # read as plain text
      language = "en"))   # language is english
  
  sotu_corpus <- tm_map(sotu_corpus, tolower)
  
  sotu_corpus <- tm_map(
    sotu_corpus, 
    removePunctuation,
    preserve_intra_word_dashes = TRUE)
  
  sotu_corpus <- tm_map(
    sotu_corpus, 
    removeWords, 
    stopwords("english"))
  
  # getStemLanguages()
  sotu_corpus <- tm_map(
    sotu_corpus, 
    stemDocument,
    lang = "porter") # try porter or english
  
  sotu_corpus <- tm_map(
    sotu_corpus, 
    stripWhitespace)
  
  # Remove specific words
  sotu_corpus <- tm_map(
    sotu_corpus, 
    removeWords, 
    c("will", "can", "get", "that", "year", "let", "may", "the"))
  
  # print(sotu_corpus[["sotu2013.txt"]][3])
  
  # Calculate Frequencies
  sotu_tdm <- TermDocumentMatrix(sotu_corpus)
  
  # Convert to term/frequency format
  sotu_matrix <- as.matrix(sotu_tdm)
  sotu_df <- data.frame(
    word = rownames(sotu_matrix), 
    # necessary to call rowSums if have more than 1 document
    freq = rowSums(sotu_matrix),
    stringsAsFactors = FALSE) 
  
  # Sort by frequency
  sotu_df <- sotu_df[with(
    sotu_df, 
    order(freq, decreasing = TRUE)), ]
  
  # Do not need the row names anymore
  rownames(sotu_df) <- NULL
  
  return(sotu_df)
  # Check out final data frame
  # View(sotu_df)
}

sotu_df80 <- words_frequency("1980")
sotu_df80$prop <- sotu_df80$freq/sum(sotu_df80$freq)*100
sotu_df90 <- words_frequency("1990")
sotu_df90$prop <- sotu_df90$freq/sum(sotu_df90$freq)*100

sotu_df <- merge(sotu_df80, sotu_df90, by=c("word"), all.x=T, all.y=T)
names(sotu_df) <- c("word", "freq80", "prop80", "freq90", "prop90")
sotu_df <- sotu_df[order(-sotu_df$prop80),]