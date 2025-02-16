/* BART model: 'Risk aversion'
*  author: Alex Pike
*  email: alex.pike02@gmail.com
*/

data {
  int<lower=1> N;             // Number of subjects
  int<lower=1> T;             // Maximum number of trials
  int<lower=0> Tsubj[N];      // Number of trials for each subject
  int<lower=2> P;             // Number of max pump + 1 ** CAUTION **
  int<lower=0> pumps[N, T];   // Number of pump
  // int<lower=0> reward[N, T];  // Amount of rewards
  int<lower=0,upper=1> explosion[N, T];  // Whether the balloon exploded (0 or 1)
}

transformed data {
  // Whether a subject pump the button or not (0 or 1)
  int d[N, T, P];

  for (j in 1:N) {
    for (k in 1:Tsubj[j]) {
      for (l in 1:P) {
        if (l <= pumps[j, k])
          d[j, k, l] = 1;
        else
          d[j, k, l] = 0;
      }
    }
  }
}

parameters {
  // Group-level parameters
  real mu_pr;
  real<lower=0> sigma;

  // Normally distributed error for Matt trick
  vector[N] risk_aversion_pr;
}

transformed parameters {
  // Subject-level parameters with Matt trick
  vector<lower=0>[N] risk_aversion;

  for (i in 1:N){
      risk_aversion[i]=exp(mu_pr + sigma * risk_aversion_pr[i]);
  }
}

model {
  // Prior
  mu_pr  ~ normal(0, 1);
  sigma ~ normal(0, 0.2); // cauchy(0, 5);

  risk_aversion_pr ~ normal(0, 1);

  // Likelihood
  for (j in 1:N) {
    real pump_belief = 10;

    for (k in 1:Tsubj[j]) {
      real u_gain;
      real u_loss;
      real p_burst;
      real ev;

      for (l in 1:(pumps[j, k] + 1 - explosion[j, k])) {
        p_burst = 1/(pump_belief+1-l);
        if ((p_burst<0)||(p_burst>1)){ //essentially detects if pump_belief is >l+1
          p_burst=1;
        }
        u_gain = l;
        u_loss = (l-1);

        ev = (1 - p_burst) * u_gain - p_burst * u_loss - pow((p_burst*(1-p_burst)),risk_aversion[j]);
        //basic expected value computation

        // Calculate likelihood with bernoulli distribution
        d[j, k, l] ~ bernoulli_logit(ev);
      }
    }
  }
}

generated quantities {
  // Actual group-level mean
  real mu_risk_aversion = exp(mu_pr);

  // Log-likelihood for model fit
  real log_lik[N];

  // For posterior predictive check
  real y_pred[N, T, P];
  real ev;

  // Set all posterior predictions to 0 (avoids NULL values)
  for (j in 1:N)
    for (k in 1:T)
      for(l in 1:P)
        y_pred[j, k, l] = 999;

  { // Local section to save time and space
    for (j in 1:N) {
      real pump_belief = 10;

      log_lik[j] = 0;

      for (k in 1:Tsubj[j]) {
        real u_gain;
        real u_loss;
        real p_burst;

        for (l in 1:(pumps[j, k] + 1 - explosion[j, k])) {
          p_burst = 1/(pump_belief+1-l);
          if ((p_burst<0)||(p_burst>1)){ //essentially detects if pump_belief is >l+1
            p_burst=1;
          }
          u_gain = l;
          u_loss = (l - 1);

          ev = (1 - p_burst) * u_gain - p_burst * u_loss - pow((p_burst*(1-p_burst)),risk_aversion[j]);

          log_lik[j] += bernoulli_logit_lpmf(d[j, k, l] | ev);
          y_pred[j, k, l] = bernoulli_logit_rng(ev);
        }
      }
    }
  }
}


