context("Test bart_withintrial_2par")
library(hBayesDM)

test_that("Test bart_withintrial_2par", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_withintrial_2par(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
