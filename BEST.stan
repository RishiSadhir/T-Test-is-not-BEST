/*
  Author: Rishi Sadhir
  Date: 10/19/2019

  This program tests multi group difference based hypotheses
  using a t distribution to make these diferences more robust to
  outliers. The program is robust to each group having different
  variances.

  Posterior differences are calculated for the first two groups by default.
  Additional contrasts need to be calculated externally.
 */

data {
  // Metadata
  int<lower=1> N;                           // Sample size
  int<lower=2> N_groups;                    // Number of groups

  // Observed data
  vector[N] outcome;                        // Outcome variable
  int<lower=1, upper=N_groups> group_id[N]; // Group variable
}

transformed data {
  real mean_outcome;
  real sd_outcome;
  mean_outcome = mean(outcome);
  sd_outcome = sd(outcome);
}

parameters {
  vector[N_groups] alpha;              // Group means
  vector<lower=0>[N_groups] gamma;     // Group std. deviations
  real<lower=0, upper=100> nu;         // df for t distribution
}

model {
  real location;
  real scale;

  // Priors are weakly skeptical of differences
  alpha ~ normal(mean_outcome, sd_outcome);
  gamma ~ cauchy(0, 1);
  nu ~ exponential(1.0/29);

  // Likelihood
  for (n in 1:N){
    location = alpha[group_id[n]];
    scale = gamma[group_id[n]];
    outcome[n] ~ student_t(nu, location, scale);
  }
}
generated quantities {
  real mu_diff;
  real sigma_diff;
  mu_diff = alpha[1] - alpha[2];
  sigma_diff = gamma[1] - gamma[2];
}
