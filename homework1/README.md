Homework 1: Basic Charts
==============================

| **Name**  | Dora (Weiran) Wang  |
|----------:|:-------------|
| **Email** | wwang48@dons.usfca.edu |

## Instructions ##

The following packages must be installed prior to running this code:

- `ggplot2`
- `gridExtra`

To run this code, please enter the following commands in R:

```
source_url("https://github.com/doraw880/msan622/tree/master/homework1/Basic Charts.R")
```

This will generate 4 images. See below for details.

## Discussion ##

In the first three movie images, movies with the same genre are assigned to the same color, and the colors are gradient with the increase of movie count in one genre. To achieve this, I firstly made a new dataset which only has genre and movie count, reordered it by count, and gave the color rank to each genre. Then, I merged the movies dataset with the color rank.

```R
> print(genre_count)
        genre count color
6       Mixed  1771     1
5       Drama  1201     2
7        None   869     3
3      Comedy   713     4
1      Action   340     5
9       Short   135     6
4 Documentary    82     7
8     Romance    41     8
2   Animation    31     9
```

```R
> movies[c("genre", "budget", "rating", "color")][sample(1:nrow(movies), 10), ]
      genre   budget rating color
582  Comedy    25000    8.3     4
4483   None  1200000    4.2     3
2887  Mixed     1000    6.5     1
171  Action  8000000    4.1     5
3635  Mixed  8000000    6.8     1
3107  Mixed 20000000    5.3     1
4208   None  3000000    6.1     3
2467  Mixed    30000    7.5     1
4853   None 25000000    5.6     3
2110  Drama   175000    7.0     2
```

The color rank column was used as the colors in the images, and `scale_colour_brewer(palette="RdYlGn")` was added to limit the colors into three main colors. Therefore, the genre with more movies has redder color, the genre with less movies has greener color, and the one with median number of movies has yellow color.

![IMAGE](hw1-scatter.png)

For the scatter above, I devided the values of x-axis text by 1000000, and added "(Million Dollars)" to the x-axis titles. I also changed the labels and name of the legend to make it more readable.

![IMAGE](hw1-bar.png)

For the bar chart above, to emphasize which genre has more movies, I ordered the genres by their movie counts and put the genre with more movies ahead. I also removed the legend as it provides the same color information as the bar charts, i.e. which color represents which genre. 

![IMAGE](hw1-multiples.png)

For the multiple scatters above, I reordered the small scatters so that the orders of genres are consistent with those in the bar chart. Now, it is clear that the genre on the top and left has the largest number of movies, and the genre on the bottom and right has the smallest number of movies. It is also consistent with the color gradients.

![IMAGE](hw1-multiline.png)

For the multiple lines above, I created a new dataset which has three columns: price, time and index, and converted the original data to the new dataset using `rbind`. Then I transfered the type of time column to numeric and created the multiple lines grouped by the index.

All titles, axis labels and axis texts in the four images are changed to "serif" family font.