#' @templateVar MODEL_FUNCTION bart_prospect_belief_learning
#' @templateVar CONTRIBUTOR \href{https://apike02.github.io/}{Alex Pike} <\email{alex.pike@@ucl.ac.uk}>
#' @templateVar TASK_NAME Balloon Analogue Risk Task
#' @templateVar TASK_CODE bart
#' @templateVar TASK_CITE 
#' @templateVar MODEL_NAME Simple model with a prior belief that is updated IF there is an explosion or the pumps are greater than the prior
#' @templateVar MODEL_CODE prospect_belief_learning
#' @templateVar MODEL_CITE 
#' @templateVar MODEL_TYPE Hierarchical
#' @templateVar DATA_COLUMNS "subjID", "pumps", "explosion"
#' @templateVar PARAMETERS \code{pumps_prior_belief} (prior belief of burst), \code{learning_rate} (rate at which belief of burst is updated)
#' @templateVar REGRESSORS 
#' @templateVar POSTPREDS "y_pred", "ev (expected value on each pump)"
#' @templateVar LENGTH_DATA_COLUMNS 3
#' @templateVar DETAILS_DATA_1 \item{subjID}{A unique identifier for each subject in the data-set.}
#' @templateVar DETAILS_DATA_2 \item{pumps}{The number of pumps.}
#' @templateVar DETAILS_DATA_3 \item{explosion}{0: intact, 1: burst}
#' @templateVar LENGTH_ADDITIONAL_ARGS 0
#' 
#' @template model-documentation
#'
#' @export
#' @include hBayesDM_model.R
#' @include preprocess_funcs.R



bart_prospect_belief_learning <- hBayesDM_model(
  task_name       = "bart",
  model_name      = "prospect_belief_learning",
  model_type      = "",
  data_columns    = c("subjID", "pumps", "explosion"),
  parameters      = list(
    "pumps_prior_belief" = c(0, 10, Inf),
    "learning_rate" = c(0, 0.5, 1)
  ),
  regressors      = NULL,
  postpreds       = c("y_pred", "ev (expected value on each pump)"),
  preprocess_func = bart_preprocess_func)
