context("Test bart_prospect_learning")
library(hBayesDM)

test_that("Test bart_prospect_learning", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_prospect_learning(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
