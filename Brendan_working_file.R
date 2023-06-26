# Hello
library(cmdstanr)


# \dontrun{
file <- file.path("ecoregion_system_full_model_final.stan")
# file <- file.path("ecoregion_system_full_model_un-nested.stan")
# file <- file.path("ecoregion_system_full_model_un-nested_ncp.stan")


# by default compilation happens when cmdstan_model() is called.
# to delay compilation until calling the $compile() method set compile=FALSE
mod <- cmdstan_model(file, pedantic=TRUE)

#mod$compile()
#mod$exe_file()

# # turn on threading support (for using functions that support within-chain parallelization)
# mod$compile(force_recompile = TRUE, cpp_options = list(stan_threads = TRUE))
# mod$exe_file()

num_covariates = 3
N = 2500
num_ecoregions = 10
num_systems = 2
y = rnorm(N) 
eco_idx = sample(1:num_ecoregions,N, replace=T)
system_idx = rbinom(N, 1, 0.995)+1
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


fit$summary(variables = c("beta_mu_global"))
fit$summary(variables = c("beta_sigma_global"))
fit$summary(variables = c("beta_system"))
fit$summary(variables = c("level_2_sigma"))
fit$summary(variables = c("y_sim"))

library("posterior")
posterior_draws = as_draws_rvars(fit$draws())

beta_mu_global = subset_draws(posterior_draws, variable = "beta_mu_global")
beta_sigma_global = subset_draws(posterior_draws, variable = "beta_sigma_global")

#beta_system = subset_draws(posterior_draws, variable = "beta_system", chain = 1:2, iteration = 1:5)
beta_system = subset_draws(posterior_draws, variable = "beta_system")
summarize_draws(beta_system)

beta_eco = subset_draws(posterior_draws, variable = "beta_eco")
summarize_draws(beta_eco)

level_2_sigma = subset_draws(posterior_draws, variable = "level_2_sigma")
summarize_draws(level_2_sigma)

library(bayesplot)
mcmc_pairs(posterior_draws, pars = c("beta_mu_global[1]", "beta_mu_global[2]"))

mcmc_pairs(posterior_draws, pars = c("beta_system[1,1]", "beta_system[2,1]")) # Between system
mcmc_pairs(posterior_draws, pars = c("beta_system[1,1]", "beta_system[1,2]")) # Within system


mcmc_pairs(posterior_draws, pars = c("beta_eco[1,1,1]", "beta_eco[1,2,1]"))

mcmc_pairs(posterior_draws, pars = c("beta_eco[1,1,1]", "beta_eco[2,1,1]"))

mcmc_pairs(posterior_draws, pars = c("beta_system[1,1]", "beta_sigma_global[1]"))
mcmc_pairs(posterior_draws, pars = c("beta_system_raw[1,1]", "beta_sigma_global[1]"))


# mcmc_pairs(posterior_draws, pars = c("beta_eco[1,1]", "level_2_sigma[1]"))
# 
# mcmc_pairs(posterior_draws, pars = c("beta_eco_raw[1,1]", "level_2_sigma[1]"))

y_sim = subset_draws(posterior_draws, variable = "y_sim")
y_sim_matrix= as_draws_matrix(y_sim)
hist(y_sim_matrix[1,])

hist(y_sim_matrix)
sd(y_sim_matrix)
mean(y_sim_matrix)

beta_mu_matrix = as_draws_matrix(beta_mu_global)
beta_mu_matrix[1,]
hist(beta_mu_matrix)

beta_sigma_matrix = as_draws_matrix(beta_sigma_global)
beta_sigma_matrix[1,]
hist(beta_sigma_matrix)

level_2_sigma_matrix = as_draws_matrix(level_2_sigma)
level_2_sigma_matrix[1,]
hist(level_2_sigma_matrix)

beta_system = as_draws_matrix(beta_system)
beta_system[1,]
hist(level_2_sigma_matrix)

y_synthetic = as.numeric(y_sim_matrix[1,])



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
beta_mu_global = subset_draws(posterior_draws_synth, variable = "beta_mu_global")
level_2_sigma = subset_draws(posterior_draws_synth, variable = "level_2_sigma")
beta_system = subset_draws(posterior_draws_synth, variable = "beta_system")
beta_eco= subset_draws(posterior_draws_synth, variable = "beta_eco")

beta_system

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


