#' Convert Factors to Strings
#'
#' \code{step_factor2string} will convert one or more factor
#'  vectors to strings.
#'
#' @inheritParams step_center
#' @inherit step_center return
#' @param ... One or more selector functions to choose which
#'  variables will converted to strings See \code{\link{selections}}
#'  for more details. For the \code{tidy} method, these are not
#'  currently used.
#' @param role Not used by this step since no new variables are
#'  created.
#' @param columns A character string of variables that will be
#'  converted. This is \code{NULL} until computed by
#'  \code{\link{prep.recipe}}.
#' @return An updated version of \code{recipe} with the new step
#'  added to the sequence of existing steps (if any). For the
#'  \code{tidy} method, a tibble with columns \code{terms} (the
#'  columns that will be affected).
#' @keywords datagen
#' @concept preprocessing variable_encodings factors
#' @export
#' @details \code{prep} has an option \code{stringsAsFactors} that
#'  defaults to \code{TRUE}. If this step is used with the default
#'  option, the string(s() produced by this step will be converted
#'  to factors after all of the steps have been prepped.
#' @seealso \code{\link{step_string2factor}} \code{\link{step_dummy}}
#' @examples
#' data(okc)
#'
#' rec <- recipe(~ diet + location, data = okc)
#'
#' rec <- rec %>%
#'   step_string2factor(diet)
#'
#' factor_test <- rec %>%
#'   prep(training = okc,
#'        stringsAsFactors = FALSE,
#'        retain = TRUE) %>%
#'   juice
#' # diet is a
#' class(factor_test$diet)
#'
#' rec <- rec %>%
#'   step_factor2string(diet)
#'
#' string_test <- rec %>%
#'   prep(training = okc,
#'        stringsAsFactors = FALSE,
#'        retain = TRUE) %>%
#'   juice
#' # diet is a
#' class(string_test$diet)
#'
#' tidy(rec, number = 1)
step_factor2string <-
  function(recipe,
           ...,
           role = NA,
           trained = FALSE,
           columns = FALSE) {
    add_step(
      recipe,
      step_factor2string_new(
        terms = check_ellipses(...),
        role = role,
        trained = trained,
        columns = columns
      )
    )
  }

step_factor2string_new <-
  function(terms = NULL,
           role = NA,
           trained = FALSE,
           columns = NULL) {
    step(
      subclass = "factor2string",
      terms = terms,
      role = role,
      trained = trained,
      columns = columns
    )
  }

#' @export
prep.step_factor2string <- function(x, training, info = NULL, ...) {
  col_names <- terms_select(x$terms, info = info)
  fac_check <-
    vapply(training[, col_names], is.factor, logical(1))
  if (any(!fac_check))
    stop(
      "The following variables are not factor vectors: ",
      paste0("`", names(fac_check)[!fac_check], "`", collapse = ", "),
      call. = FALSE
    )

  step_factor2string_new(
    terms = x$terms,
    role = x$role,
    trained = TRUE,
    columns = col_names
  )
}


#' @importFrom purrr map_df
#' @export
bake.step_factor2string <- function(object, newdata, ...) {
  newdata[, object$columns] <-
    map_df(newdata[, object$columns],
           as.character)

  if (!is_tibble(newdata))
    newdata <- as_tibble(newdata)
  newdata
}

print.step_factor2string <-
  function(x, width = max(20, options()$width - 30), ...) {
    cat("Character variables from ")
    printer(x$columns, x$terms, x$trained, width = width)
    invisible(x)
  }


#' @rdname step_factor2string
#' @param x A \code{step_factor2string} object.
tidy.step_factor2string <- function(x, ...) {
  simple_terms(x, ...)
}