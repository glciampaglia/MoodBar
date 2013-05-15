% A sample report
% Giovanni Luca Ciampaglia
% `r date()`

<!-- set up R -->
`ro warning=FALSE, dev="pdf", fig.cap="", cache=FALSE or`

<!-- read script -->
```{r reading, echo=FALSE}
read_chunk("active.R")
```

```{r}
<<read-data>>
```

```{r}
<<prep-data>>
```

```{r plot-fig1, result="asis", dev="pdf"}
<<plot-diff>>
```

```{r plot-fig2, result="asis", dev="pdf"}
<<plot-all>>
```

" vim:ft=markdown
