#include /pre/license.stan

data {
  int<lower=1> N;            // Number of subjects
  int<lower=1> T;            // Maximum number of trials
  int<lower=0> Tsubj[N];     // Number of trials for each subject
  int<lower=2> P;            // Number of max pump + 1 ** CAUTION **
  int<lower=0> pumps[N, T];  // Number of pump
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
  vector[2] mu_pr;
  vector<lower=0>[2] sigma;

  // Normally distributed error for Matt trick
  vector[N] phi_pr;
  vector[N] gam_pr;
}

transformed parameters {
  // Subject-level parameters with Matt trick
  vector<lower=0,upper=1>[N] phi;
  vector<lower=0>[N] gam;

  phi = Phi_approx(mu_pr[1] + sigma[1] * phi_pr);
  gam = exp(mu_pr[2] + sigma[2] * gam_pr);
}

model {
  // Prior
  mu_pr  ~ normal(0, 1);
  sigma ~ normal(0, 0.2);

  phi_pr ~ normal(0, 1);
  gam_pr ~ normal(0, 1);

  // Likelihood
  for (j in 1:N) {
    // Initialize n_succ and n_pump for a subject
    int n_succ = 0;  // Number of successful pumps
    int n_pump = 0;  // Number of total pumps

    for (k in 1:Tsubj[j]) {
      real p_burst;  // Belief on a balloon to be burst
      real omega;    // Optimal number of pumps

      p_burst = 1 - ((phi[j] + 0 * n_succ) / (1 + 0 * n_pump));
      omega = -gam[j] / log1m(p_burst);

      // Calculate likelihood with bernoulli distribution
      for (l in 1:(pumps[j, k] + 1 - explosion[j, k]))
        d[j, k, l] ~ bernoulli_logit(omega - l);

      // Update n_succ and n_pump after each trial ends
      n_succ += pumps[j, k] - explosion[j, k];
      n_pump += pumps[j, k];
    }
  }
}

generated quantities {
  // Actual group-level mean
  real<lower=0, upper=1> mu_phi = Phi_approx(mu_pr[1]);
  real<lower=0> mu_gam = exp(mu_pr[2]);

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
      int n_succ = 0;
      int n_pump = 0;

      log_lik[j] = 0;

      for (k in 1:Tsubj[j]) {
        real p_burst;  // Belief on a balloon to be burst
        real omega;    // Optimal number of pumps

        p_burst = 1 - ((phi[j] + 0 * n_succ) / (1 + 0 * n_pump));
        omega = -gam[j] / log1m(p_burst);

        for (l in 1:(pumps[j, k] + 1 - explosion[j, k])) {
          log_lik[j] += bernoulli_logit_lpmf(d[j, k, l] | omega - l);
          y_pred[j, k, l] = bernoulli_logit_rng(omega - l);
        }

        n_succ += pumps[j, k] - explosion[j, k];
        n_pump += pumps[j, k];
      }
    }
  }
}

