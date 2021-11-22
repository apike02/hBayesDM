context("Test bart_prospect_belief_lossaversion")
library(hBayesDM)

test_that("Test bart_prospect_belief_lossaversion", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_prospect_belief_lossaversion(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
