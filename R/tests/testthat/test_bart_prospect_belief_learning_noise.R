context("Test bart_prospect_belief_learning_noise")
library(hBayesDM)

test_that("Test bart_prospect_belief_learning_noise", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_prospect_belief_learning_noise(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
