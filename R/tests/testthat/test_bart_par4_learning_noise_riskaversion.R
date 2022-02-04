context("Test bart_par4_learning_noise_riskaversion")
library(hBayesDM)

test_that("Test bart_par4_learning_noise_riskaversion", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_par4_learning_noise_riskaversion(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
