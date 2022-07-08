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
  vector[4] mu_pr;
  vector<lower=0>[4] sigma;

  // Normally distributed error for Matt trick
  vector[N] target_pumps_pr;
  vector[N] rewsens_pr;
  vector[N] punsens_pr;
  vector[N] noise_pr;
}

transformed parameters {
  // Subject-level parameters with Matt trick
  vector<lower=0>[N] target_pumps;
  vector<lower=0,upper=1>[N] rewsens;
  vector<lower=0,upper=1>[N] punsens;
  vector<lower=0>[N] noise;

  target_pumps = exp(mu_pr[1] + sigma[1] * target_pumps_pr);
  rewsens =      Phi_approx(mu_pr[2] + sigma[2] * rewsens_pr);
  punsens =      Phi_approx(mu_pr[3] + sigma[3] * punsens_pr);
  noise =        exp(mu_pr[4] + sigma[4] * noise_pr);
}

model {
  // Prior
  mu_pr  ~ normal(0, 1);
  sigma  ~ normal(0, 0.2);

  target_pumps_pr ~ normal(0, 1);
  rewsens_pr ~ normal(0, 1);
  punsens_pr ~ normal(0, 1);
  noise_pr ~ normal(0, 1);

  int pump_max = P;

  // Likelihood
  for (j in 1:N) {
    // Initialize n_succ and n_pump for a subject
    int n_succ = 0;  // Number of successful pumps
    int n_pump = 0;  // Number of total pumps
    int success = 0; // Whether last trial was explosion or success
    real actual_target_pumps = target_pumps[j];

    for (k in 1:Tsubj[j]) {
      if (success==1){
        actual_target_pumps = actual_target_pumps*(1+rewsens[j]*(n_pump*1.0/pump_max));
      } else {
        actual_target_pumps = actual_target_pumps*(1-punsens[j]*(1-n_pump*1.0/pump_max));
      }

      // Calculate likelihood with bernoulli distribution
      for (l in 1:(pumps[j, k] + 1 - explosion[j, k])){
        d[j, k, l] ~ bernoulli_logit(noise[j] * (actual_target_pumps - l));
      }

      // Update n_succ and n_pump after each trial ends
      n_pump = pumps[j, k];
      success = 1 - explosion[j,k];
    }
  }
}

generated quantities {
  // Actual group-level mean
  real<lower=0, upper=1> mu_target_pumps = Phi_approx(mu_pr[1]);
  real<lower=0> mu_rewsens = exp(mu_pr[2]);
  real<lower=0> mu_punsens = exp(mu_pr[3]);
  real<lower=0> mu_noise = exp(mu_pr[4]);

  // Log-likelihood for model fit
  real log_lik[N];

  // For posterior predictive check
  real y_pred[N, T, P];

  // Define pump max
  int pump_max = P;


  // Set all posterior predictions to 0 (avoids NULL values)
  for (j in 1:N)
    for (k in 1:T)
      for(l in 1:P)
        y_pred[j, k, l] = -1;

  { // Local section to save time and space
    for (j in 1:N) {
      int n_succ = 0;
      int n_pump = 0;
      int success = 0;
      real actual_target_pumps = target_pumps[j];


      log_lik[j] = 0;

      for (k in 1:Tsubj[j]) {
        if (success==1){
          actual_target_pumps = actual_target_pumps*(1+rewsens[j]*(n_pump*1.0/pump_max));
        } else {
          actual_target_pumps = actual_target_pumps*(1-punsens[j]*(1-n_pump*1.0/pump_max));
        }

        for (l in 1:(pumps[j, k] + 1 - explosion[j, k])) {
          log_lik[j] += bernoulli_logit_lpmf(d[j, k, l] | noise[j] * (actual_target_pumps - l));
          y_pred[j, k, l] = bernoulli_logit_rng(noise[j] * (actual_target_pumps - l));
        }

        n_pump = pumps[j, k];
        success = 1 - explosion[j,k];
      }
    }
  }
}

