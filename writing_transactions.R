library(dplyr)

set.seed(123)

n_transactions = 10000
#sample values for proof of concept
transactions = data.frame(
  amount = rnorm(n_transactions, mean = 100, sd = 50),
  location = sample(c("US", "Europe", "Asia"), n_transactions, replace = TRUE),
  time = sample(c("day", "night"), n_transactions, replace = TRUE),
  is_fraudulent = sample(c(0, 1), n_transactions, replace = TRUE, prob = c(0.98, 0.02))
)

write.csv(transactions, "transactions.csv", row.names = FALSE)

head(transactions)
