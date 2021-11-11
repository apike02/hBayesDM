#' @templateVar MODEL_FUNCTION bart_prospect_riskaversion
#' @templateVar CONTRIBUTOR \href{https://apike02.github.io/}{Alex Pike} <\email{alex.pike@@ucl.ac.uk}>
#' @templateVar TASK_NAME Balloon Analogue Risk Task
#' @templateVar TASK_CODE bart
#' @templateVar TASK_CITE 
#' @templateVar MODEL_NAME Simple model with summative risk aversion only
#' @templateVar MODEL_CODE prospect_riskaversion
#' @templateVar MODEL_CITE 
#' @templateVar MODEL_TYPE Hierarchical
#' @templateVar DATA_COLUMNS "subjID", "pumps", "explosion"
#' @templateVar PARAMETERS \code{risk_aversion} (additive value that makes you less likely to pump)
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



bart_prospect_riskaversion <- hBayesDM_model(
  task_name       = "bart",
  model_name      = "prospect_riskaversion",
  model_type      = "",
  data_columns    = c("subjID", "pumps", "explosion"),
  parameters      = list(
    "risk_aversion" = c(-Inf, 0, Inf)
  ),
  regressors      = NULL,
  postpreds       = c("y_pred", "ev (expected value on each pump)"),
  preprocess_func = bart_preprocess_func)
