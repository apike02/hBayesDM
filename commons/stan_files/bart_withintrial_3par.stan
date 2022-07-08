#include /pre/license.stan

data {
  int<lower=1> N;            // Number of subjects
  int<lower=1> T;            // Maximum number of trials
  int<lower=0> Tsubj[N];     // Number of trials for each subject
  int<lower=2> P;            // Number of max pump + 1 ** CAUTION **
  int<lower=0> pumps[N, T];  // Number of pumps
  int<lower=0,upper=1> explosion[N, T];  // Whether the balloon exploded (0 or 1)
}

transformed data{
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
  vector[3] mu_pr;
  vector<lower=0>[3] sigma;

  // Normally distributed error for Matt trick
  vector[N] target_pumps_pr;
  vector[N] risk_taking_pr;
  vector[N] noise_pr;
}

transformed parameters {
  // Subject-level parameters with Matt trick
  vector<lower=0>[N] target_pumps;
  vector<lower=0,upper=5>[N] risk_taking;
  vector<lower=0>[N] noise;

  target_pumps = exp(mu_pr[1] + sigma[1] * target_pumps_pr);
  risk_taking =  Phi_approx(mu_pr[2] + sigma[2] * risk_taking_pr)*5;
  noise =        exp(mu_pr[3] + sigma[3] * noise_pr);
}

model {
  // Prior
  mu_pr  ~ normal(0, 1.0);
  sigma  ~ normal(0, 0.2);

  target_pumps_pr ~ normal(0, 1.0);
  risk_taking_pr ~ normal(0, 1.0);
  noise_pr ~ normal(0, 1.0);

  // Likelihood
  for (j in 1:N) {
    real actual_target_pumps = target_pumps[j];

    for (k in 1:Tsubj[j]) {
      for (l in 1:(pumps[j, k] + 1 - explosion[j, k])){
        if (l>actual_target_pumps){
          actual_target_pumps += risk_taking[j];
        }
        // Calculate likelihood with bernoulli distribution
        d[j, k, l] ~ bernoulli_logit(noise[j] * (actual_target_pumps - l));
      }

      // Update actual_target_pumps after trial ends
    }
  }
}

generated quantities {
  // Actual group-level mean
  real<lower=0> mu_target_pumps = exp(mu_pr[1]);
  real<lower=0,upper=1> mu_learningrate = Phi_approx(mu_pr[2]);
  real<lower=0> mu_risk_taking = Phi_approx(mu_pr[3]);
  real<lower=0> mu_noise = exp(mu_pr[4]);

  // Log-likelihood for model fit
  real log_lik[N];

  // For posterior predictive check
  real y_pred[N, T, P];

  // Set all posterior predictions to 0 (avoids NULL values)
  for (j in 1:N)
    for (k in 1:T)
      for(l in 1:P)
        y_pred[j, k, l] = -1;

  { // Local section to save time and space
    for (j in 1:N) {
      real actual_target_pumps = target_pumps[j];

      log_lik[j] = 0;

      for (k in 1:Tsubj[j]) {
        for (l in 1:(pumps[j, k] + 1 - explosion[j, k])) {
          if (l>actual_target_pumps){
            actual_target_pumps += risk_taking[j];
          }
          log_lik[j] += bernoulli_logit_lpmf(d[j, k, l] | noise[j] * (actual_target_pumps - l));
          y_pred[j, k, l] = bernoulli_logit_rng(noise[j] * (actual_target_pumps - l));
        }
      }
    }
  }
}

