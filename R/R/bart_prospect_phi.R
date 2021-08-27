#' @templateVar MODEL_FUNCTION bart_prospect_phi
#' @templateVar CONTRIBUTOR \href{https://apike02.github.io/}{Alex Pike} <\email{alex.pike@@ucl.ac.uk}>
#' @templateVar TASK_NAME Balloon Analogue Risk Task
#' @templateVar TASK_CODE bart
#' @templateVar TASK_CITE 
#' @templateVar MODEL_NAME Very simple model with only a single prior belief
#' @templateVar MODEL_CODE prospect_phi
#' @templateVar MODEL_CITE (Park et al., 2020)
#' @templateVar MODEL_TYPE Hierarchical
#' @templateVar DATA_COLUMNS "subjID", "pumps", "explosion"
#' @templateVar PARAMETERS \code{phi} (prior belief of burst)
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

#' @references
#' Park, H., Yang, J., Vassileva, J., & Ahn, W. (2020). The Exponential-Weight Mean-Variance Model: A novel computational model for the Balloon Analogue Risk Task. https://doi.org/10.31234/osf.io/sdzj4
#'


bart_prospect_phi <- hBayesDM_model(
  task_name       = "bart",
  model_name      = "prospect_phi",
  model_type      = "",
  data_columns    = c("subjID", "pumps", "explosion"),
  parameters      = list(
    "phi" = c(0, 0.5, 1)
  ),
  regressors      = NULL,
  postpreds       = c("y_pred", "ev (expected value on each pump)"),
  preprocess_func = bart_preprocess_func)
