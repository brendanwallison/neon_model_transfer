# neon_model_transfer

# Joint Modeling of error across NEON and FIA

## Forestry Model

Model for biomass, based on diameter at breast height (DBH):

$$\mathrm{Biomass} = e^{\beta_0 + \beta_1 \cdot \log(DBH)}$$

$$\text{Productivity} = \frac{\Delta Biomass}{\Delta Time}$$

$$\text{Productivity }= \text{f}(\mathbf{X})$$

Factors $\beta_0$ and $\beta_1$ determine growth rate by species.  A list of approximations can be found [here](https://github.com/frec-3044/machine-learning-template/blob/main/assignment/data/neon_biomass.csv).  An overall approximation for hardwood and softwood can be found in the [Jenkins 2003](https://github.com/frec-3044/land-carbon-template/blob/main/assignment/Jenkins_etal_2003_FS.pdf).

# FIA Data Dxtraction

# NEON Data Extraction 

* Download woody vegetation structure [DP1.10098.001](https://data.neonscience.org/data-products/DP1.10098.001)


## Selection of sites:
We selected Ordway Swisher, Jones Ecological Research Center, Taladega National Forest, and Oak Ridge.

## Using Git
https://rfortherestofus.com/2021/02/how-to-use-git-github-with-r/


## USEPA Level 3 Ecoregions
https://www.epa.gov/eco-research/level-iii-and-iv-ecoregions-continental-united-states

## Probability distributions
Exploring Gamma Priors with the Probability Playground:
https://www.acsu.buffalo.edu/~adamcunn/probability/negativebinomial.html
