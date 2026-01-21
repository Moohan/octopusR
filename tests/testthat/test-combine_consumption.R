# Test data: a list of simple data frames
test_data_list <- list(
  data.frame(x = 1, y = "a"),
  data.frame(x = 2, y = "b")
)

test_that("combine_consumption_data uses data.table::rbindlist if available", {
  mock_is_installed <- function(pkg) pkg == "data.table"
  mock_rbindlist <- mockery::mock(cycle = TRUE)

  octopusR:::combine_consumption_data(
    test_data_list,
    is_installed = mock_is_installed,
    rbindlist_fun = mock_rbindlist
  )

  mockery::expect_called(mock_rbindlist, 1)
})

test_that("combine_consumption_data uses vctrs::vec_rbind if available and data.table is not", {
  mock_is_installed <- function(pkg) pkg == "vctrs"
  mock_vec_rbind <- mockery::mock(cycle = TRUE)

  octopusR:::combine_consumption_data(
    test_data_list,
    is_installed = mock_is_installed,
    vec_rbind_fun = mock_vec_rbind
  )

  mockery::expect_called(mock_vec_rbind, 1)
})

test_that("combine_consumption_data uses dplyr::bind_rows if available and others are not", {
  mock_is_installed <- function(pkg) pkg == "dplyr"
  mock_bind_rows <- mockery::mock(cycle = TRUE)

  octopusR:::combine_consumption_data(
    test_data_list,
    is_installed = mock_is_installed,
    bind_rows_fun = mock_bind_rows
  )

  mockery::expect_called(mock_bind_rows, 1)
})

test_that("combine_consumption_data falls back to do.call(rbind, ...) when no suggested packages are installed", {
  mock_is_installed <- function(pkg) FALSE

  result <- octopusR:::combine_consumption_data(
    test_data_list,
    is_installed = mock_is_installed
  )

  expected <- do.call(rbind, test_data_list)
  expect_equal(result, expected)
})
