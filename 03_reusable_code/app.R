library(shiny)
library(ggplot2)

# Load and preprocess the Iris dataset
iris_data <- read.csv("iris.data.txt")
names(iris_data) <- c("sepal_length","sepal_width","petal_length","petal_width","species")
X <- as.matrix(iris_data[, 1:4])

# Standardize to mean 0 and sd 1
mu <- colMeans(X)
sdv <- apply(X, 2, sd)
Xst <- scale(X, center = mu, scale = sdv)

# From scratch k means implementation 
sq_euclidean <- function(A, B) {
  n <- nrow(A)
  k <- nrow(B)
  d <- ncol(A)
  D2 <- matrix(0, nrow = n, ncol = k)

  for (i in 1:n) {
    for (j in 1:k) {
      s <- 0
      for (p in 1:d) {
        diff <- A[i, p] - B[j, p]
        s <- s + diff * diff}
      D2[i, j] <- s}}
  D2}

assign_clusters <- function(Xst, centers) {
  D2 <- sq_euclidean(Xst, centers)
  max.col(-D2, ties.method = "first")}

recompute_centers <- function(Xst, clusters, k) {
  d <- ncol(Xst)
  centers <- matrix(0, nrow = k, ncol = d)

  for (j in 1:k) {
    idx <- which(clusters == j)

    # Guard: if a cluster becomes empty, re-seed its center with a random point.
    if (length(idx) == 0) {
      centers[j, ] <- Xst[sample(nrow(Xst), 1), ]} 
    else {
      centers[j, ] <- colMeans(Xst[idx, , drop = FALSE])}}

  colnames(centers) <- colnames(Xst)
  centers}

inertia_total <- function(Xst, centers, clusters) {
  total <- 0
  for (i in 1:nrow(Xst)) {
    c_idx <- clusters[i]
    diff  <- Xst[i, ] - centers[c_idx, ]
    total <- total + sum(diff^2)}
  total}

kmeans_from_scratch <- function(Xst, k, max_iter = 100) {
  n <- nrow(Xst)

  # Initialize centers by sampling k data points
  centers  <- Xst[sample(n, k, replace = FALSE), , drop = FALSE]
  clusters <- assign_clusters(Xst, centers)

  for (iter in 1:max_iter) {
    new_centers  <- recompute_centers(Xst, clusters, k)
    new_clusters <- assign_clusters(Xst, new_centers)

    if (all(new_clusters == clusters)) {
      centers  <- new_centers
      clusters <- new_clusters
      break}

    centers  <- new_centers
    clusters <- new_clusters}

  inertia <- inertia_total(Xst, centers, clusters)

  list(
    centers = centers,
    clusters = clusters,
    inertia = inertia,
    iterations = iter)}

# Shiny input for different k values
ui <- fluidPage(
  titlePanel("Iris k-means"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("k", "Number of clusters (k)", min = 2, max = 10, value = 3, step = 1),
      helpText("fixed seed, max_iter = 100")),
    mainPanel(
      plotOutput("cluster_plot", height = 520),
      verbatimTextOutput("summary_text"),
      tableOutput("cluster_sizes"))))

server <- function(input, output, session) {

  fit <- reactive({
    set.seed(500355)
    kmeans_from_scratch(Xst, k = input$k, max_iter = 100)})

  output$cluster_plot <- renderPlot({
    f <- fit()

    df_plot <- data.frame(
      X1 = Xst[, 1],
      X2 = Xst[, 2],
      cluster = factor(f$clusters))

    centers_df <- data.frame(
      X1 = f$centers[, 1],
      X2 = f$centers[, 2],
      cluster = factor(1:nrow(f$centers)))

    ggplot(df_plot, aes(x = X1, y = X2, color = cluster)) +
      geom_point(size = 3, alpha = 0.9) +
      geom_point(
        data = centers_df,
        aes(x = X1, y = X2),
        inherit.aes = FALSE,
        shape = 4, size = 6, stroke = 1.5) +
      theme_minimal() +
      theme(legend.position = "right") +
      labs(
        title = paste("k-means on Iris data (k =", input$k, ")"),
        subtitle = "Points = observations; X = cluster centers",
        x = "Sepal.Length (standardized)",
        y = "Sepal.Width (standardized)",
        color = "Cluster")})

  output$summary_text <- renderPrint({
    f <- fit()
    cat("iterations:", f$iterations, "\n")
    cat("inertia:", round(f$inertia, 3), "\n")})

  output$cluster_sizes <- renderTable({
    f <- fit()
    as.data.frame(table(cluster = f$clusters))})}

shinyApp(ui, server)
