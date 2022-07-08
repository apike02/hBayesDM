context("Test bart_stl")
library(hBayesDM)

test_that("Test bart_stl", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_stl(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
