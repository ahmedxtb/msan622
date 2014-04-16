Project: Dataset
==============================

| **Name**  | Dora (Weiran) Wang  |
|----------:|:-------------|
| **Email** | wwang48@dons.usfca.edu |

## Discussion ##

### Clean Data ###

I downloaded 6 data sets from the websites. They are "Life.Exp", "Fertility.Rate", "Birth.Rate", "Death.Rate", "Population" and "Country.Map". I need to combine them to a single data set for later use. I took the following steps to merge them together.

- For each data set (except "Country.Map" which has different structure), I filtered out all the rows which contains any NAs. I also removed useless columns such as "Indicator.Code".
- The original data set includes all the year variables. I added a "year" variable, and converted each row from the original data set into a vertical way.

```
> head(Birth.Rate[, c(1,2, 5:8)]) # original data
  Country.Name Country.Code    X1960    X1961   X1962   X1963
1        Aruba          ABW 35.67900 34.52900 33.3200 32.0500
2      Andorra          AND       NA       NA      NA      NA
3  Afghanistan          AFG 53.73000 53.72600 53.7150 53.6960
4       Angola          AGO 54.48700 54.43600 54.3460 54.2130
5      Albania          ALB 42.24000 41.26600 40.2290 39.1860
6   Arab World          ARB 48.06425 47.77806 47.4754 47.1513
```

```
> head(Birth.Rate.new) # converted data
      Country.Name Country.Code year Birth.Rate
X1960        Aruba          ABW 1960     35.679
X1961        Aruba          ABW 1961     34.529
X1962        Aruba          ABW 1962      33.32
X1963        Aruba          ABW 1963      32.05
X1964        Aruba          ABW 1964     30.737
X1965        Aruba          ABW 1965     29.413
```

- The data sets have a similar structure, so I merged them together by "Country.Name", "Country.Code" and "year"
- "Country.Map" includes information such as region and income group for each country. Finally, I combined "Country.Map" to the data set. The cleaned data is shown as follows.

```
> head(combined.data)
  Country.Code                    Region          IncomeGroup Country.Name year Birth.Rate Death.Rate Fertility.Rate    Life.Exp Population
1          ABW Latin America & Caribbean High income: nonOECD        Aruba 1980     22.473      6.376          2.392 72.22014634      60096
2          ABW Latin America & Caribbean High income: nonOECD        Aruba 1981     22.424      6.445          2.377 72.46234146      60567
3          ABW Latin America & Caribbean High income: nonOECD        Aruba 1982      22.33      6.519          2.364 72.67319512      61344
4          ABW Latin America & Caribbean High income: nonOECD        Aruba 1983     22.188      6.603          2.353 72.84902439      62204
5          ABW Latin America & Caribbean High income: nonOECD        Aruba 1984     21.989      6.694          2.342  72.9897561      62831
6          ABW Latin America & Caribbean High income: nonOECD        Aruba 1985     21.727      6.786          2.332 73.09797561      63028
```
