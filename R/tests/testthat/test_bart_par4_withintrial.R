context("Test bart_par4_withintrial")
library(hBayesDM)

test_that("Test bart_par4_withintrial", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_par4_withintrial(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
