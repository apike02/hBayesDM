context("Test bart_prospect_phi")
library(hBayesDM)

test_that("Test bart_prospect_phi", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_prospect_phi(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
