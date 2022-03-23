#include /pre/license.stan

data {
  int<lower=1> N;
  int<lower=1> T;
  int<lower=1, upper=T> Tsubj[N];
  int<lower=1, upper=4> cue[N, T];
  int<lower=-1, upper=1> pressed[N, T];
  real outcome[N, T];
}

transformed data {
  vector[4] initV;
  initV = rep_vector(0.0, 4);
}

parameters {
  // declare as vectors for vectorizing
  vector[7] mu_pr;
  vector<lower=0>[7] sigma;
  vector[N] xi_pr;         // noise
  vector[N] win_ep_pr;     // win learning rate
  vector[N] loss_ep_pr;    // loss learning rate
  vector[N] b_pr;          // go bias
  vector[N] pi_pr;         // pavlovian  bias
  vector[N] rhoRew_pr;     // rho reward, inv temp
  vector[N] rhoPun_pr;     // rho punishment, inv temp
}

transformed parameters {
  vector<lower=0, upper=1>[N] xi;
  vector<lower=0, upper=1>[N] win_ep;
  vector<lower=0, upper=1>[N] loss_ep;
  vector[N] b;
  vector[N] pi;
  vector<lower=0>[N] rhoRew;
  vector<lower=0>[N] rhoPun;

  for (i in 1:N) {
    xi[i]  = Phi_approx(mu_pr[1] + sigma[1] * xi_pr[i]);
    win_ep[i]  = Phi_approx(mu_pr[2] + sigma[2] * win_ep_pr[i]);
    loss_ep[i] = Phi_approx(mu_pr[3] + sigma[3] * loss_ep_pr[i]);
  }
  b      = mu_pr[4] + sigma[4] * b_pr; // vectorization
  pi     = mu_pr[5] + sigma[5] * pi_pr;
  rhoRew = exp(mu_pr[6] + sigma[6] * rhoRew_pr);
  rhoPun = exp(mu_pr[7] + sigma[7] * rhoPun_pr);
}

model {
// gng_m7: RW(rew/pun) + noise + bias + pavlovian + 2lr
  // hyper parameters
  mu_pr[1]  ~ normal(0, 1.0);
  mu_pr[2]  ~ normal(0, 1.0);
  mu_pr[3]  ~ normal(0, 1.0);
  mu_pr[4]  ~ normal(0, 10.0);
  mu_pr[5]  ~ normal(0, 10.0);
  mu_pr[6]  ~ normal(0, 1.0);
  mu_pr[7]  ~ normal(0, 1.0);
  sigma[1:3] ~ normal(0, 0.2);
  sigma[4:5] ~ cauchy(0, 1.0);
  sigma[6:7] ~ normal(0, 0.2);

  // individual parameters w/ Matt trick
  xi_pr      ~ normal(0, 1.0);
  win_ep_pr  ~ normal(0, 1.0);
  loss_ep_pr ~ normal(0, 1.0);
  b_pr       ~ normal(0, 1.0);
  pi_pr      ~ normal(0, 1.0);
  rhoRew_pr  ~ normal(0, 1.0);
  rhoPun_pr  ~ normal(0, 1.0);

  for (i in 1:N) {
    vector[4] wv_g;  // action weight for go
    vector[4] wv_ng; // action weight for nogo
    vector[4] qv_g;  // Q value for go
    vector[4] qv_ng; // Q value for nogo
    vector[4] sv;    // stimulus value
    vector[4] pGo;   // prob of go (press)

    wv_g  = initV;
    wv_ng = initV;
    qv_g  = initV;
    qv_ng = initV;
    sv    = initV;

    for (t in 1:Tsubj[i]) {
      wv_g[cue[i, t]]  = qv_g[cue[i, t]] + b[i] + pi[i] * sv[cue[i, t]];
      wv_ng[cue[i, t]] = qv_ng[cue[i, t]];  // qv_ng is always equal to wv_ng (regardless of action)
      pGo[cue[i, t]]   = inv_logit(wv_g[cue[i, t]] - wv_ng[cue[i, t]]);
      {  // noise
        pGo[cue[i, t]]   *= (1 - xi[i]);
        pGo[cue[i, t]]   += xi[i]/2;
      }
      pressed[i, t] ~ bernoulli(pGo[cue[i, t]]);

      // after receiving feedback, update sv[t + 1]
      // after receiving feedback, update sv[t + 1]
      if ((cue[i, t] == 1 )||( cue[i, t] == 3)){
        if (outcome[i, t] > 0) {
          sv[cue[i, t]] += win_ep[i] * (rhoRew[i] * outcome[i, t] - sv[cue[i, t]]);
        } else if (outcome[i, t] ==0){
          sv[cue[i, t]] += loss_ep[i] * (rhoPun[i] * outcome[i, t] - sv[cue[i, t]]);
        }
      } else if ((cue[i, t] == 2 )|| (cue [i, t] == 4)){
        if (outcome[i, t] == 0) {
          sv[cue[i, t]] += win_ep[i] * (rhoRew[i] * outcome[i, t] - sv[cue[i, t]]);
        } else if (outcome[i, t] < 0){
          sv[cue[i, t]] += loss_ep[i] * (rhoPun[i] * outcome[i, t] - sv[cue[i, t]]);
        }
      }

      // update action values
      if (pressed[i, t]) { // update go value
        if ((cue[i, t] ==1 )||( cue [i, t] == 3)) {
          if (outcome [i, t] > 0){
            qv_g[cue[i, t]] += win_ep[i] * (rhoRew[i] * outcome[i, t] - qv_g[cue[i, t]]);
          } else if (outcome [i, t] == 0){
            qv_g[cue[i, t]] += loss_ep[i] * (rhoPun[i] * outcome[i, t] - qv_g[cue[i, t]]);
          }
        } else if ((cue[i, t] == 2 )|| (cue [i, t] == 4)){
          if (outcome [i, t] == 0){
            qv_g[cue[i, t]] += win_ep[i] * (rhoRew[i] * outcome[i, t] - qv_g[cue[i, t]]);
          } else if (outcome [i, t] < 0){
            qv_g[cue[i, t]] += loss_ep[i] * (rhoPun[i] * outcome[i, t] - qv_g[cue[i, t]]);
          }
        }
      } else { // update no-go value
        if ((cue[i, t] ==1 )||( cue [i, t] == 3)) {
          if (outcome [i, t] > 0){
            qv_ng[cue[i, t]] += win_ep[i] * (rhoRew[i] * outcome[i, t] - qv_ng[cue[i, t]]);
          } else if (outcome [i, t] == 0){
            qv_ng[cue[i, t]] += loss_ep[i] * (rhoPun[i] * outcome[i, t] - qv_ng[cue[i, t]]);
          }
        } else if ((cue[i, t] == 2 )||( cue [i, t] == 4)){
          if (outcome [i, t] == 0){
            qv_ng[cue[i, t]] += win_ep[i] * (rhoRew[i] * outcome[i, t] - qv_ng[cue[i, t]]);
          } else if (outcome [i, t] < 0){
            qv_ng[cue[i, t]] += loss_ep[i] * (rhoPun[i] * outcome[i, t] - qv_ng[cue[i, t]]);
          }
        }
      }
    } // end of t loop
  } // end of i loop
}

generated quantities {
  real<lower=0, upper=1> mu_xi;
  real<lower=0, upper=1> mu_win_ep;
  real<lower=0, upper=1> mu_loss_ep;
  real mu_b;
  real mu_pi;
  real<lower=0> mu_rhoRew;
  real<lower=0> mu_rhoPun;
  real log_lik[N];
  real Qgo[N, T];
  real Qnogo[N, T];
  real Wgo[N, T];
  real Wnogo[N, T];
  real SV[N, T];

  // For posterior predictive check
  real y_pred[N, T];

  // Set all posterior predictions to 0 (avoids NULL values)
  for (i in 1:N) {
    for (t in 1:T) {
      y_pred[i, t] = -1;
    }
  }

  mu_xi     = Phi_approx(mu_pr[1]);
  mu_win_ep = Phi_approx(mu_pr[2]);
  mu_loss_ep= Phi_approx(mu_pr[3]);
  mu_b      = mu_pr[4];
  mu_pi    = mu_pr[5];
  mu_rhoRew = exp(mu_pr[6]);
  mu_rhoPun = exp(mu_pr[7]);

  { // local section, this saves time and space
    for (i in 1:N) {
      vector[4] wv_g;  // action weight for go
      vector[4] wv_ng; // action weight for nogo
      vector[4] qv_g;  // Q value for go
      vector[4] qv_ng; // Q value for nogo
      vector[4] sv;    // stimulus value
      vector[4] pGo;   // prob of go (press)

      wv_g  = initV;
      wv_ng = initV;
      qv_g  = initV;
      qv_ng = initV;
      sv    = initV;

      log_lik[i] = 0;

      for (t in 1:Tsubj[i]) {
        wv_g[cue[i, t]]  = qv_g[cue[i, t]] + b[i] + pi[i] * sv[cue[i, t]];
        wv_ng[cue[i, t]] = qv_ng[cue[i, t]];  // qv_ng is always equal to wv_ng (regardless of action)
        pGo[cue[i, t]]   = inv_logit(wv_g[cue[i, t]] - wv_ng[cue[i, t]]);
        {  // noise
          pGo[cue[i, t]]   *= (1 - xi[i]);
          pGo[cue[i, t]]   += xi[i]/2;
        }
        log_lik[i] += bernoulli_lpmf(pressed[i, t] | pGo[cue[i, t]]);

        // generate posterior prediction for current trial
        y_pred[i, t] = bernoulli_rng(pGo[cue[i, t]]);

        // Model regressors --> store values before being updated
        Qgo[i, t]   = qv_g[cue[i, t]];
        Qnogo[i, t] = qv_ng[cue[i, t]];
        Wgo[i, t]   = wv_g[cue[i, t]];
        Wnogo[i, t] = wv_ng[cue[i, t]];
        SV[i, t]    = sv[cue[i, t]];

        // after receiving feedback, update sv[t + 1]
        if ((cue[i, t] == 1 )|| (cue[i, t] == 3)){
          if (outcome[i, t] > 0) {
            sv[cue[i, t]] += win_ep[i] * (rhoRew[i] * outcome[i, t] - sv[cue[i, t]]);
          } else if (outcome[i, t] ==0){
            sv[cue[i, t]] += loss_ep[i] * (rhoPun[i] * outcome[i, t] - sv[cue[i, t]]);
          }
        } else if ((cue[i, t] == 2 )||( cue [i, t] == 4)){
          if (outcome[i, t] == 0) {
            sv[cue[i, t]] += win_ep[i] * (rhoRew[i] * outcome[i, t] - sv[cue[i, t]]);
          } else if (outcome[i, t] < 0){
            sv[cue[i, t]] += loss_ep[i] * (rhoPun[i] * outcome[i, t] - sv[cue[i, t]]);
          }
        }
  
        // update action values
        if (pressed[i, t]) { // update go value
          if ((cue[i, t] ==1 )||( cue [i, t] == 3)) {
            if (outcome [i, t] > 0){
              qv_g[cue[i, t]] += win_ep[i] * (rhoRew[i] * outcome[i, t] - qv_g[cue[i, t]]);
            } else if (outcome [i, t] == 0){
              qv_g[cue[i, t]] += loss_ep[i] * (rhoPun[i] * outcome[i, t] - qv_g[cue[i, t]]);
            }
          } else if ((cue[i, t] == 2) || (cue [i, t] == 4)){
            if (outcome [i, t] == 0){
              qv_g[cue[i, t]] += win_ep[i] * (rhoRew[i] * outcome[i, t] - qv_g[cue[i, t]]);
            } else if (outcome [i, t] < 0){
              qv_g[cue[i, t]] += loss_ep[i] * (rhoPun[i] * outcome[i, t] - qv_g[cue[i, t]]);
            }
          }
        } else { // update no-go value
          if ((cue[i, t] ==1 )|| (cue [i, t] == 3)) {
            if (outcome [i, t] > 0){
              qv_ng[cue[i, t]] += win_ep[i] * (rhoRew[i] * outcome[i, t] - qv_ng[cue[i, t]]);
            } else if (outcome [i, t] == 0){
              qv_ng[cue[i, t]] += loss_ep[i] * (rhoPun[i] * outcome[i, t] - qv_ng[cue[i, t]]);
            }
          } else if ((cue[i, t] == 2 )|| (cue [i, t] == 4)){
            if (outcome [i, t] == 0){
              qv_ng[cue[i, t]] += win_ep[i] * (rhoRew[i] * outcome[i, t] - qv_ng[cue[i, t]]);
            } else if (outcome [i, t] < 0){
              qv_ng[cue[i, t]] += loss_ep[i] * (rhoPun[i] * outcome[i, t] - qv_ng[cue[i, t]]);
            }
          }
        }
      } // end of t loop
    } // end of i loop
  } // end of local section
}

