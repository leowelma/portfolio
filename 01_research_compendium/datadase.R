set.seed(365300)

# 1. Participants
n_participants <- 24
participants <- sprintf("P%02d", 1:n_participants)

# 2. Items: 2 (color) x 2 (format) x 3 items per cell = 12 items
items <- expand.grid(
  color  = c(0, 1),   # 0 = absent, 1 = present
  format = c(0, 1),   # 0 = per100, 1 = perServing
  k      = 1:3
)
items$item <- with(items, sprintf("I_c%df%d_%d", color, format, k))

# 3. Random intercepts for participants and items
u_participant <- rnorm(n_participants, mean = 0.2, sd = 0.6)
names(u_participant) <- participants

u_item <- rnorm(nrow(items), mean = 0.2, sd = 0.4)
names(u_item) <- items$item

# 4. Fixed effects tuned to target probabilities
# Target (for average participant/item):

beta_0      <- -0.125 # intercept (no color, per100)
beta_color  <-  0.605 # effect of color present
beta_format <-  0.515 # effect of perServing
beta_int    <- 0.015 # interaction

logistic <- function(x) 1 / (1 + exp(-x))

# 5. Generate trial-level data
rows <- list()
for (p in participants) {
  for (i in seq_len(nrow(items))) {
    it <- items[i, ]
    
    linpred <- beta_0 +
      beta_color  * it$color +
      beta_format * it$format +
      beta_int    * it$color * it$format +
      u_participant[p] +
      u_item[it$item]
    
    prob <- logistic(linpred)
    correct <- rbinom(1, size = 1, prob = prob)
    
    rows[[length(rows) + 1]] <- data.frame(
      participant = p,
      item        = it$item,
      color       = ifelse(it$color == 1, "present", "absent"),
      format      = ifelse(it$format == 1, "perServing", "per100"),
      correct     = correct
    )
  }
}

toy_df <- do.call(rbind, rows)

# 6. Save to CSV
write.csv(toy_df, "toy_df.csv", row.names = FALSE)
head(toy_df)
table(toy_df$color, toy_df$format, toy_df$correct)
