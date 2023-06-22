data {
  int<lower=1> num_covariates;
  int<lower=0> N;
  int<lower=1> num_ecoregions;
  array[N] int<lower=0, upper=1> y;
  array[N] int<lower=1, upper=num_ecoregions> eco_idx;
  array[N] row_vector[num_covariates] x;
}
parameters {
  array[num_covariates] real beta_mu_global;
  array[num_covariates] real<lower=0> beta_sigma_global;
  array[num_covariates] real<lower=0> sigma_1_global;
  array[num_covariates] real<lower=0> sigma_2_global;
  array[num_ecoregions] vector[num_covariates] real<lower=0> sigma_eco;
  array[num_ecoregions] vector[num_covariates] beta_eco;
}
model {
  for (c in 1:num_covariates) {
    beta_mu_global[c] ~ normal(0, 1);
    beta_sigma_global[c] ~ gamma(0.1, 0.1);
    sigma_1_global[c] ~ gamma(0.1, 0.1);
    sigma_2_global[c] ~ gamma(0.1, 0.1);    
    
    for (eco in 1:num_ecoregions) {
      beta_eco[eco, c] ~ normal(beta_mu_global[c], beta_sigma_global[c]);
    }
    for (eco in 1:num_ecoregions) {
      sigma_eco[eco, c] ~ gamma(sigma_1_global[c], sigma_2_global[c])
    }
  }
  for (n in 1:N) {
    y[n] ~ normal(x[n] * beta_eco[eco_idx[n]], sigma_eco[eco_idx[n]]);
  }
}