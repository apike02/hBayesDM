#' @templateVar MODEL_FUNCTION bart_withintrial
#' @templateVar CONTRIBUTOR \href{https://ccs-lab.github.io/team/harhim-park/}{Harhim Park} <\email{hrpark12@@gmail.com}>, \href{https://ccs-lab.github.io/team/jaeyeong-yang/}{Jaeyeong Yang} <\email{jaeyeong.yang1125@@gmail.com}>, \href{https://ccs-lab.github.io/team/ayoung-lee/}{Ayoung Lee} <\email{aylee2008@@naver.com}>, \href{https://ccs-lab.github.io/team/jeongbin-oh/}{Jeongbin Oh} <\email{ows0104@@gmail.com}>, \href{https://ccs-lab.github.io/team/jiyoon-lee/}{Jiyoon Lee} <\email{nicole.lee2001@@gmail.com}>, \href{https://ccs-lab.github.io/team/junha-jang/}{Junha Jang} <\email{andy627robo@@naver.com}>, \href{https://apike02.github.io/}{Alex Pike} <\email{alex.pike02@@gmail.com}>
#' @templateVar TASK_NAME Balloon Analogue Risk Task
#' @templateVar TASK_CODE bart
#' @templateVar TASK_CITE 
#' @templateVar MODEL_NAME BART model where the number of pumps is updated within trials
#' @templateVar MODEL_CODE withintrial
#' @templateVar MODEL_CITE 
#' @templateVar MODEL_TYPE Hierarchical
#' @templateVar DATA_COLUMNS "subjID", "pumps", "explosion"
#' @templateVar PARAMETERS \code{target_pumps} (prior expectation for how many pumps result in explosion), \code{learningrate} (learning rate - scales learning post-trial), \code{risk_taking} (risk taking parameter - scales tendency to press more within-trial), \code{noise} (inverse temperature)
#' @templateVar REGRESSORS 
#' @templateVar POSTPREDS "y_pred"
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



bart_withintrial <- hBayesDM_model(
  task_name       = "bart",
  model_name      = "withintrial",
  model_type      = "",
  data_columns    = c("subjID", "pumps", "explosion"),
  parameters      = list(
    "target_pumps" = c(0, 1, Inf),
    "learningrate" = c(0, 0.5, 1),
    "risk_taking" = c(0, 0.5, 1),
    "noise" = c(0, 1, Inf)
  ),
  regressors      = NULL,
  postpreds       = c("y_pred"),
  preprocess_func = bart_preprocess_func)
