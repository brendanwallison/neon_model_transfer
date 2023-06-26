data {
  int<lower=1> num_covariates;
  int<lower=0> N;
  int<lower=1> num_ecoregions;
  int<lower=1> num_systems;
  int<lower = 0, upper = 1> run_estimation;
  array[N] real y;
  array[N] int<lower=1, upper=num_ecoregions> eco_idx;
  array[N] int<lower=1, upper=num_systems> system_idx;
  array[N] row_vector[num_covariates] x;
}
parameters {
  array[num_covariates] real beta_mu_global;
  array[num_covariates] real<lower=0> beta_sigma_global;
  array[num_covariates] real<lower=0> level_2_sigma;
  array[num_systems] vector[num_covariates] beta_system_raw;
  array[num_ecoregions, num_systems] vector[num_covariates] beta_eco_raw;
  real<lower=0> observation_sigma;
}
transformed parameters {
  array[num_systems] vector[num_covariates] beta_system;
  array[num_ecoregions, num_systems] vector[num_covariates] beta_eco;
  for (c in 1:num_covariates) {
    for (system in 1:num_systems) {
      beta_system[system, c] = beta_system_raw[system, c]*beta_sigma_global[c] + beta_mu_global[c];
    }
    for (system in 1:num_systems) {    
      for (eco in 1:num_ecoregions){
          beta_eco[eco, system, c] = beta_eco_raw[eco, system, c] * level_2_sigma[c] + beta_system[system, c];
      }
    }
  }
}
model {
  beta_mu_global ~ std_normal();
  observation_sigma ~ exponential(10);
  for (c in 1:num_covariates) {
    beta_sigma_global[c] ~ exponential(10);
    level_2_sigma[c] ~ exponential(5);
    beta_system_raw[, c] ~ std_normal();
    // for (system in 1:num_systems) {
    //   //beta_system[system, c] ~ normal(beta_mu_global[c], beta_sigma_global[c]);
    //   
    // }
    for (system in 1:num_systems) {
      for (eco in 1:num_ecoregions){
          //implies: beta_eco[eco, system, c] ~ normal(beta_system[system, c], level_2_sigma[c]);
          beta_eco_raw[eco, system, c] ~ std_normal();
      }
    }
  }
  if(run_estimation==1){
    for (n in 1:N) {
      y[n] ~ normal(x[n] * beta_eco[eco_idx[n], system_idx[n]], observation_sigma);
    }
  }
}
generated quantities{
  vector[N] y_sim;
  for (n in 1:N) {
    y_sim[n] = normal_rng(x[n] * beta_eco[eco_idx[n], system_idx[n]], observation_sigma);
  }
}
