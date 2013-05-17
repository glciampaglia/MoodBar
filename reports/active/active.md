% A sample report
% Giovanni Luca Ciampaglia
% `r date()`

<!-- set up R -->
```{r warning=FALSE, dev="pdf", fig.cap="", cache=FALSE}
```

<!-- read script -->
```{r reading, echo=FALSE}
read_chunk("active.R")
```

```{r, echo=FALSE}
<<read-data>>
```

```{r, echo=FALSE}
<<prep-data>>
```

```{r plot-fig1, result="asis", dev="pdf", echo=FALSE}
<<plot-diff>>
```

```{r plot-fig2, result="asis", dev="pdf", echo=FALSE}
<<plot-all>>
```

<!--
" vim:ft=markdown 
-->
