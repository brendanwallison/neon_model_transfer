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
  corr_matrix[num_covariates] Omega_global;
  array[num_systems] corr_matrix[num_covariates] Omega_system;
  array[num_ecoregions] corr_matrix[num_covariates] Omega_eco; 
  row_vector<lower=0>[num_covariates] tau_global;
  array[num_systems] row_vector<lower=0>[num_covariates] tau_system;
  array[num_ecoregions] row_vector<lower=0>[num_covariates] tau_eco;
  array[num_systems, num_ecoregions] vector[num_covariates] beta;
  vector<lower=0>[num_systems] obs_sigma;
  simplex[3] ro;
}
transformed parameters {
  array[num_systems, num_ecoregions] corr_matrix[num_covariates] Omega;
  array[num_systems, num_ecoregions] row_vector[num_covariates] tau; 
  vector[N] yhat;
  vector[N] sigmahat;
  for (sys in 1:num_systems) {
    for (eco in 1:num_ecoregions) {
      Omega[sys, eco] = Omega_global*ro[1] + Omega_system[sys]*ro[2] + Omega_eco[eco]*ro[3]; //weighted average
      tau[sys, eco] = tau_global + tau_system[sys] + tau_eco[eco];
    }
  }
  for (n in 1:N) {
    yhat[n] = x[n] * beta[system_idx[n], eco_idx[n]];
    sigmahat[n] = obs_sigma[system_idx[n]];
  }
}
model {
  Omega_global ~ lkj_corr(1);
  tau_global ~ exponential(2);
  for (sys in 1:num_systems){
    Omega_system[sys] ~ lkj_corr(10);    
    obs_sigma[sys] ~ exponential(2);
    tau_system[sys] ~ exponential(2);
  }
  for (eco in 1:num_ecoregions){
    Omega_eco[eco] ~ lkj_corr(10); 
    tau_eco[eco] ~ exponential(2);
  }
  ro ~ dirichlet([10, 1, 2]);
  for (sys in 1:num_systems) {
    for (eco in 1:num_ecoregions) {
      beta[sys, eco] ~ multi_normal(rep_vector(0, num_covariates), quad_form_diag(Omega[sys, eco], tau[sys, eco]));
    }
  }
  if(run_estimation==1){
    y ~ normal(yhat, sigmahat);
  }
}
generated quantities{
  array[N] real y_sim;
  y_sim = normal_rng(yhat, sigmahat);
}
