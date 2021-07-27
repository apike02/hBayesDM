context("Test bart_ewmv_minustau")
library(hBayesDM)

test_that("Test bart_ewmv_minustau", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_ewmv_minustau(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
