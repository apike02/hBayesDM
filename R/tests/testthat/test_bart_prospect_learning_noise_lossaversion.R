context("Test bart_prospect_learning_noise_lossaversion")
library(hBayesDM)

test_that("Test bart_prospect_learning_noise_lossaversion", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_prospect_learning_noise_lossaversion(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
