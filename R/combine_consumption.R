# Internal helper to combine list of consumption data frames
#
# This function provides a performance-optimized way to row-bind a list of
# data frames. It checks for the presence of recommended packages and uses the
# fastest available method.
#
# @param data_list A list of data frames to be row-bound.
#
# @return A single data frame.
# @noRd
combine_consumption_data <- function(data_list,
                                     is_installed = rlang::is_installed,
                                     rbindlist_fun = NULL,
                                     vec_rbind_fun = NULL,
                                     bind_rows_fun = NULL) {
  # Using data.table::rbindlist(), vctrs::vec_rbind(), or dplyr::bind_rows()
  # provides a significant performance boost over the base R alternative of
  # do.call(rbind, ...).
  if (is_installed("data.table")) {
    if (is.null(rbindlist_fun)) {
      rbindlist_fun <- utils::getFromNamespace("rbindlist", "data.table")
    }
    return(rbindlist_fun(data_list))
  } else if (is_installed("vctrs")) {
    if (is.null(vec_rbind_fun)) {
      vec_rbind_fun <- utils::getFromNamespace("vec_rbind", "vctrs")
    }
    spliced_args <- rlang::list2(!!!data_list)
    return(do.call(vec_rbind_fun, spliced_args))
  } else if (is_installed("dplyr")) {
    if (is.null(bind_rows_fun)) {
      bind_rows_fun <- utils::getFromNamespace("bind_rows", "dplyr")
    }
    return(bind_rows_fun(data_list))
  } else {
    return(do.call(rbind, data_list))
  }
}
