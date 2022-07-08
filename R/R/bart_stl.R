#' @templateVar MODEL_FUNCTION bart_stl
#' @templateVar CONTRIBUTOR \href{https://ccs-lab.github.io/team/harhim-park/}{Harhim Park} <\email{hrpark12@@gmail.com}>, \href{https://ccs-lab.github.io/team/jaeyeong-yang/}{Jaeyeong Yang} <\email{jaeyeong.yang1125@@gmail.com}>, \href{https://ccs-lab.github.io/team/ayoung-lee/}{Ayoung Lee} <\email{aylee2008@@naver.com}>, \href{https://ccs-lab.github.io/team/jeongbin-oh/}{Jeongbin Oh} <\email{ows0104@@gmail.com}>, \href{https://ccs-lab.github.io/team/jiyoon-lee/}{Jiyoon Lee} <\email{nicole.lee2001@@gmail.com}>, \href{https://ccs-lab.github.io/team/junha-jang/}{Junha Jang} <\email{andy627robo@@naver.com}>, \href{https://apike02.github.io/}{Alex Pike} <\email{alex.pike02@@gmail.com}>
#' @templateVar TASK_NAME Balloon Analogue Risk Task
#' @templateVar TASK_CODE bart
#' @templateVar TASK_CITE 
#' @templateVar MODEL_NAME BART model from https://doi.org/10.1016/j.cogpsych.2021.101407
#' @templateVar MODEL_CODE stl
#' @templateVar MODEL_CITE (Zhou et al., 2021)
#' @templateVar MODEL_TYPE Hierarchical
#' @templateVar DATA_COLUMNS "subjID", "pumps", "explosion"
#' @templateVar PARAMETERS \code{target_pumps} (prior expectation for how many pumps result in explosion), \code{rewsens} (reward sensitivity), \code{punsens} (punishment sensitivity), \code{noise} (inverse temperature)
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

#' @references
#' Zhou, R., Myung, J. I., & Pitt, M.A. (2021). The scaled target learning model: Revisiting learning in the balloon analogue risk task. Cognitive Psychology, 128, 101407.
#'


bart_stl <- hBayesDM_model(
  task_name       = "bart",
  model_name      = "stl",
  model_type      = "",
  data_columns    = c("subjID", "pumps", "explosion"),
  parameters      = list(
    "target_pumps" = c(0, 1, Inf),
    "rewsens" = c(0, 0.5, 1),
    "punsens" = c(0, 0.5, 1),
    "noise" = c(0, 1, Inf)
  ),
  regressors      = NULL,
  postpreds       = c("y_pred"),
  preprocess_func = bart_preprocess_func)
