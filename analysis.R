# Hello
library(cmdstanr)

file <- file.path("ecoregion_system_full_model_un-nested_beta-covariance.stan")
mod <- cmdstan_model(file, pedantic=TRUE)

# # turn on threading support (for using functions that support within-chain parallelization)
# mod$compile(force_recompile = TRUE, cpp_options = list(stan_threads = TRUE))
# mod$exe_file()

num_covariates = 3
N = 10000
num_ecoregions = 10
num_systems = 2
y = rnorm(N) 
eco_idx = sample(1:num_ecoregions,N, replace=T)
system_idx = rbinom(N, 1, 0.99)+1
#system_idx = sample(1:num_systems,N, replace=T)
x = matrix( rnorm(N*num_covariates,mean=0,sd=1), N, num_covariates) 


data_list <- list(num_covariates=num_covariates, N=N, 
                  num_ecoregions=num_ecoregions, run_estimation=0, 
                  num_systems=num_systems, y=y, eco_idx=eco_idx, 
                  system_idx=system_idx, x=x)

fit <- mod$sample(
  data = data_list, 
  seed = 123, 
  chains = 4, 
  parallel_chains = 4,
  refresh = 250 # print update every 500 iters
)


fit$summary(variables = c("Omega_global"))
fit$summary(variables = c("Omega_eco"))
fit$summary(variables = c("Omega_system"))
fit$summary(variables = c("ro"))
fit$summary(variables = c("tau_eco"))
fit$summary(variables = c("tau_system"))
fit$summary(variables = c("beta"))
fit$summary(variables = c("y_sim"))

library("posterior")
posterior_draws = as_draws_rvars(fit$draws())


Omega_global = subset_draws(posterior_draws, variable = "Omega_global")
Omega_system = subset_draws(posterior_draws, variable = "Omega_system")
Omega_eco = subset_draws(posterior_draws, variable = "Omega_eco")
ro = subset_draws(posterior_draws, variable = "ro")
tau_eco = subset_draws(posterior_draws, variable = "tau_eco")
tau_system = subset_draws(posterior_draws, variable = "tau_system")
beta = subset_draws(posterior_draws, variable = "beta")
y_sim = subset_draws(posterior_draws, variable = "y_sim")

# example
summarize_draws(ro)
summarize_draws(Omega_global)
summarize_draws(Omega_system)

library(bayesplot)
mcmc_pairs(posterior_draws, pars = c("Omega_global[2,1]", "Omega_global[3,1]"))
mcmc_pairs(posterior_draws, pars = c("Omega_system[1,2,1]", "Omega_system[1,3,1]"))
mcmc_pairs(posterior_draws, pars = c("Omega_eco[1,2,1]", "Omega_eco[1,3,1]"))

mcmc_pairs(posterior_draws, pars = c("ro[1]", "ro[2]")) 
mcmc_pairs(posterior_draws, pars = c("tau_eco[1,1]", "tau_eco[1,2]"))
mcmc_pairs(posterior_draws, pars = c("tau_eco[1,1]", "tau_eco[2,1]"))


mcmc_pairs(posterior_draws, pars = c("beta[1,1,1]", "beta[1,2,1]"))

mcmc_pairs(posterior_draws, pars = c("beta[1,1,1]", "beta[2,1,1]"))

mcmc_pairs(posterior_draws, pars = c("beta[1,1,1]", "ro[1]"))
mcmc_pairs(posterior_draws, pars = c("beta[1,1,1]", "Omega_global[3,1]"))
mcmc_pairs(posterior_draws, pars = c("beta[1,1,1]", "tau_eco[1,1]"))
# 
# mcmc_pairs(posterior_draws, pars = c("beta_eco_raw[1,1]", "level_2_sigma[1]"))

y_sim = subset_draws(posterior_draws, variable = "y_sim")
y_sim_matrix= as_draws_matrix(y_sim)
hist(y_sim_matrix[1,])

hist(y_sim_matrix)
sd(y_sim_matrix)
mean(y_sim_matrix)

y_synthetic = as.numeric(y_sim_matrix[1,])

ro_matrix= as_draws_matrix(ro)
ro_matrix[1,]

Omega_global_matrix= as_draws_matrix(Omega_global)
Omega_global_matrix[1,]

Omega_system_matrix= as_draws_matrix(Omega_system)
Omega_system_matrix[1,]

Omega_eco_matrix= as_draws_matrix(Omega_eco)
Omega_eco_matrix[1,]

beta_matrix = as_draws_matrix(beta)
beta_matrix[1,]

tau_system = as_draws_matrix(tau_system)
tau_system[1,]

data_list <- list(num_covariates=num_covariates, N=N, 
                  num_ecoregions=num_ecoregions, run_estimation=1, 
                  num_systems=num_systems, y=y_synthetic, eco_idx=eco_idx, 
                  system_idx=system_idx, x=x)

fit_synthetic <- mod$sample(
  data = data_list, 
  seed = 125, 
  adapt_delta = 0.9,
  max_treedepth=10,
  chains = 4, 
  parallel_chains = 4,
  refresh = 250 # print update every 500 iters
)

fit_synthetic


posterior_draws_synth = as_draws_rvars(fit_synthetic$draws())

Omega_global_synth = subset_draws(posterior_draws_synth, variable = "Omega_global")
Omega_system_synth = subset_draws(posterior_draws_synth, variable = "Omega_system")
Omega_eco_synth = subset_draws(posterior_draws_synth, variable = "Omega_eco")
ro_synth = subset_draws(posterior_draws_synth, variable = "ro")
tau_eco_synth = subset_draws(posterior_draws_synth, variable = "tau_eco")
tau_system_synth = subset_draws(posterior_draws_synth, variable = "tau_system")
tau_synth = subset_draws(posterior_draws_synth, variable = "tau")
beta_synth = subset_draws(posterior_draws_synth, variable = "beta")
y_sim_synth = subset_draws(posterior_draws_synth, variable = "y_sim")

Omega_system_matrix[1,]
Omega_system_synth

Omega_eco_sample = Omega_eco_matrix[1,]
Omega_eco_synth

ro_matrix[1,]
ro_synth

beta_sample = beta_matrix[1,]
beta_synth

tau_eco_synth
tau_system_synth
tau_synth





beta_mu_global = subset_draws(posterior_draws_synth, variable = "beta_mu_global")
level_2_sigma = subset_draws(posterior_draws_synth, variable = "level_2_sigma")
beta_system = subset_draws(posterior_draws_synth, variable = "beta_system")
beta_eco= subset_draws(posterior_draws_synth, variable = "beta_eco")

beta_system
level_2_sigma

#mcmc_pairs(beta_mu_global)
np_cp <- nuts_params(fit_synthetic)
mcmc_parcoord(level_2_sigma, np = np_cp)
mcmc_parcoord(beta_mu_global, np = np_cp)
mcmc_parcoord(beta_eco, np = np_cp)



mcmc_pairs(posterior_draws_synth, np = np_cp, pars = c("beta_mu_global[1]", "beta_mu_global[2]"))
mcmc_pairs(posterior_draws_synth, np = np_cp, pars = c("beta_mu_global[1]", "beta_mu_global[3]"))

mcmc_pairs(posterior_draws_synth, np = np_cp, pars = c("beta_system[1,1]", "beta_system[2,1]")) # Between system
mcmc_pairs(posterior_draws_synth, np = np_cp, pars = c("beta_system[1,1]", "beta_system[1,2]")) # Within system


mcmc_pairs(posterior_draws_synth, np = np_cp, pars = c("beta_eco[1,1,1]", "beta_eco[1,2,1]"))

mcmc_pairs(posterior_draws_synth, np = np_cp, pars = c("beta_eco[1,1,1]", "beta_eco[2,1,1]"))
mcmc_pairs(posterior_draws_synth, np = np_cp, pars = c("beta_eco[1,1,1]", "beta_eco[3,1,1]"))


mcmc_pairs(posterior_draws_synth, np = np_cp, pars = c("beta_system[1,1]", "beta_sigma_global[1]"))
mcmc_pairs(posterior_draws_synth, np = np_cp, pars = c("beta_system_raw[1,1]", "beta_sigma_global[1]"))


mcmc_pairs(posterior_draws_synth, np = np_cp, pars = c("beta_eco[1,1]", "level_2_sigma[1]"))

mcmc_pairs(posterior_draws_synth, np = np_cp, pars = c("beta_eco_raw[1,1]", "level_2_sigma[1]"))


