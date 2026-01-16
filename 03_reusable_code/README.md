# Markup languages and reproducible programming in statistics

Deliverable 3: Reusable `R` code wrapped in an `R` package or `Shiny` app.

- If `R` package, link the package website and your development repository (on GitHub).
- If `Shiny app`, link the app on a `Shiny` server and your development repository (on GitHub).

See course manual for requirements.

## k-means shiny app to visualize different k values on the iris dataset

### functions

- loads the iris dataset (https://www.kaggle.com/datasets/uciml/iris)
- standardizes the four variables
- runs a 'from scrarch' k-means clustering algorithm with user-defined k value
  - initializes k centroids randomly
  - assigns each observation to the nearest centroid
  - repeated until convergence (or max iterations reached)

### visualizations

- scatter plot of sepal length vs sepal width colored by cluster
- displays total iterations to convergence
- displays total inertia (within-cluster sum of squares)
- displays cluster sizes

### packages used

- shiny
- ggplot2

