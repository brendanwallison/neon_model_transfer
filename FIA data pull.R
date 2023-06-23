#PULL FIA DATA FOR SOUTHEASTERN UNITED STATES
#Code originally written by Knott Jonathan
#Modified by Ebenezer Fatunsin

setwd("C:/Users/ebenf/OneDrive - The University of Alabama/EFI GitHub Work/FIA Data Extraction")
for (package in c("dplyr", 
                  "RSQLite",
                  "DBI"
)) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}
getwd()
### Set folder paths

# Folder with FIA SQLite database
shared_path <- file.path("C:/Users/LAB/OneDrive - The University of Alabama/EFI Github Work/SQLite_FIADB_ENTIRE/SQLite_FIADB_ENTIRE.db")
data_path <- "C:/Users/LAB/OneDrive - The University of Alabama/EFI Github Work"

con <- dbConnect(RSQLite::SQLite(), file.path(shared_path)) # connect to copy of FIA database
dbListTables(con)


### Pull in FIADB tree data
### Note: see notes on the second copy below. This is commented out
### so I can save it and not rerun (memory issues...)

tree.sql <- dbGetQuery(con, "SELECT t.plt_cn,
                                  t.invyr,
                                  t.statecd,
                                  t.unitcd,
                                  t.countycd,
                                  t.plot,
                                  t.subp,
                                  t.tree,
                                  t.condid,
                                  t.statuscd,
                                  t.spcd,
                                  t.dia,
                                  t.ht,
                                  t.htcd,
                                  t.actualht,
                                  t.treeclcd,
                                  t.cr,
                                  t.cclcd,
                                  t.treegrcd,
                                  t.stocking,
                                  t.wdldstem,
                                  t.totage,
                                  t.prevdia,
                                  t.tpa_unadj,
                                  t.tpagrow_unadj,
                                  t.drybio_bole,
                                  t.drybio_top,
                                  t.drybio_stump,
                                  t.drybio_sapling,
                                  t.drybio_wdld_spp,
                                  t.drybio_bg,
                                  t.carbon_ag,
                                  t.carbon_bg,
                                  t.drybio_ag,
                                  t.cn,
                                  p.measyear,
                                  p.measmon,
                                  p.measday,
                                  p.lat,
                                  p.lon,
                                  p.prev_plt_cn,
                                  p.kindcd
                           FROM ((plot p
                           INNER JOIN tree t on p.cn = t.plt_cn)
                           INNER JOIN cond c on p.cn = c.plt_cn)
                           WHERE p.intensity = '1'
                             AND p.invyr BETWEEN 2015 and 2019
                             AND p.statecd IN (1, 12, 13, 22, 28, 37, 45, 48, 51)
                             AND c.cond_status_cd = 1
                             AND p.plot_status_cd = 1
                             AND t.statuscd = 1
                             AND t.subp BETWEEN 1 AND 4")


# Query repeated below but commented out for note keeping
# con <- dbConnect(dbDriver("Oracle"), dbname = "fiadb01p") # connect to the database
# tree.sql <- dbGetQuery(con, "SELECT t.plt_cn, # select plot cn from the tree table
#                                   t.invyr, # inventory year
#                                   t.statecd, # state code
#                                   t.unitcd, # unit code
#                                   t.countycd, # county code
#                                   t.plot, # plot number
#                                   t.subp, # subplot number
#                                   t.tree, # tree number
#                                   t.condid, # condition id
#                                   t.statuscd, # status code (filtered for live trees below)
#                                   t.spcd, # species code
#                                   t.dia, # diameter (inches)
#                                   t.ht, # height (ft)
#                                   t.htcd, # height code
#                                   t.actualht, # actual height
#                                   t.treeclcd, # tree quality class code
#                                   t.cr, # crown ratio
#                                   t.cclcd, # crown class code
#                                   t.treegrcd, # tree grade code
#                                   t.stocking, # tree stocking code
#                                   t.wdldstem, # woodland stem code
#                                   t.totage, # total age
#                                   t.prevdia, # previous diameter for remeasured trees
#                                   t.tpa_unadj, # trees per acre adjustment factor
#                                   t.tpagrow_unadj, # trees per acre growing stock adjustement factor
#                                   t.drybio_bole, # dry biomass of the bole
#                                   t.drybio_top, # dry biomass of the top
#                                   t.drybio_stump, # dry biomass of the stump
#                                   t.drybio_sapling, # dry biomass for saplings
#                                   t.drybio_wdld_spp, # dry biomass for woodland spp
#                                   t.drybio_bg, # dry biomass belowground
#                                   t.carbon_ag, # above ground carbon
#                                   t.carbon_bg, # below ground carbon
#                                   t.drybio_ag, # dry biomass above ground
#                                   t.cn, # tree CN (ID) number
#                                   p.measyear, # plot measurement year
#                                   p.measmon, # plot measurement month
#                                   p.measday, # plot measurement day
#                                   p.lat, # latitude
#                                   p.lon, # longitude
#                                   p.prev_plt_cn, # previous measurement CN
#                                   p.kindcd # indicator of periodic or annual (panel system)
#                            FROM ((fs_fiadb.plot p # plot table
#                            INNER JOIN fs_fiadb.tree t ON p.cn = t.plt_cn) # inner joined to the tree table
#                            INNER JOIN fs_fiadb.cond c on p.cn = c.plt_cn) # and inner joined to the condition table
#                            WHERE p.intensity = '1' # plots w/ base level intensity
#                              AND p.invyr BETWEEN 1999 and 2019 # since the panel measurement system started
#                              AND p.statecd NOT IN (15, 60, 64, 66, 68, 69, 70, 72, 78) # in the CONUS + AK (no HI or territories)
#                              AND c.cond_status_cd = 1 # only forested plots
#                              AND p.plot_status_cd = 1 # where it's accessible to be measured
#                              AND t.statuscd = 1 # only keep live trees
#                              AND t.subp BETWEEN 1 AND 4") # and only ones on the four base intensity subplots
# dbDisconnect(con) # disconnect from the database

### Get more info about the plots (commented out so I don't have to run it again)

plt.sql <- dbGetQuery(con, "SELECT p.cn AS PLT_CN,
                                  p.invyr,
                                  p.prev_plt_cn,
                                  p.statecd,
                                  p.unitcd,
                                  p.countycd,
                                  p.plot,
                                  p.plot_status_cd,
                                  p.measyear,
                                  p.measmon,
                                  p.measday,
                                  p.remper,
                                  p.kindcd,
                                  p.designcd,
                                  p.rddistcd,
                                  p.watercd,
                                  p.lat,
                                  p.lon,
                                  p.elev,
                                  p.p2panel,
                                  p.ecosubcd,
                                  p.subp_examine_cd,
                                  p.intensity,
                                  p.cycle,
                                  p.subcycle,
                                  p.invasive_sampling_status_cd,
                                  p.designcd_p2a,
                                  p.manual_db,
                                  p.subpanel,
                                  c.condid,
                                  c.cond_status_cd,
                                  c.reservcd,
                                  c.owncd,
                                  c.owngrpcd,
                                  c.adforcd,
                                  c.fortypcd,
                                  c.stdage,
                                  c.stdszcd,
                                  c.fldszcd,
                                  c.sicond,
                                  c.sibase,
                                  c.sisp,
                                  c.stdorgcd,
                                  c.condprop_unadj,
                                  c.micrprop_unadj,
                                  c.subpprop_unadj,
                                  c.slope,
                                  c.aspect,
                                  c.physclcd,
                                  c.dstrbcd1,
                                  c.dstrbyr1,
                                  c.dstrbcd2,
                                  c.dstrbyr2,
                                  c.dstrbcd3,
                                  c.dstrbyr3,
                                  c.trtcd1,
                                  c.trtyr1,
                                  c.trtcd2,
                                  c.trtyr2,
                                  c.trtcd3,
                                  c.trtyr3,
                                  c.balive,
                                  c.fldage,
                                  c.carbon_down_dead,
                                  c.carbon_litter,
                                  c.carbon_soil_org,
                                  c.carbon_standing_dead,
                                  c.carbon_understory_ag,
                                  c.carbon_understory_bg,
                                  c.harvest_type1_srs,
                                  c.harvest_type2_srs,
                                  c.harvest_type3_srs,
                                  c.stand_structure_srs,
                                  c.live_canopy_cvr_pct,
                                  c.live_missing_canopy_cvr_pct,
                                  c.nbr_live_stems,
                                  c.siteclcd,
                                  e.evalid,
                                  v.start_invyr,
                                  v.end_invyr,
                                  x.eval_typ
                           FROM ((((((plot p
                           INNER JOIN cond c on p.cn = c.plt_cn)
                           INNER JOIN pop_plot_stratum_assgn e on p.cn = e.plt_cn)
                           INNER JOIN pop_stratum s on e.stratum_cn = s.cn)
                           INNER JOIN pop_estn_unit u on s.estn_unit_cn = u.cn)
                           INNER JOIN pop_eval v on u.eval_cn = v.cn)
                           INNER JOIN pop_eval_typ x on v.cn = x.eval_cn)
                           WHERE p.intensity = '1'
                             AND p.invyr BETWEEN 1999 and 2019
                             AND p.statecd IN (1, 12, 13, 22, 28, 37, 45, 48, 51)
                             AND x.eval_typ = 'EXPALL'
                             AND c.cond_status_cd = 1
                             AND p.plot_status_cd = 1")


dbDisconnect(con)
# Query repeated below but commented out for note keeping
# con <- dbConnect(dbDriver("Oracle"), dbname = "fiadb01p") # connect to the database
# plt.sql <- dbGetQuery(con, "SELECT p.cn, # plot CN
#                                   p.prev_plt_cn, # previous plot CN
#                                   p.invyr, # inventory year
#                                   p.statecd, # state code
#                                   p.unitcd, # unit code
#                                   p.countycd, # county code
#                                   p.plot, # plot number
#                                   p.plot_status_cd, # plot status code
#                                   p.measyear, # plot measurement year
#                                   p.measmon, # plot measurement month
#                                   p.measday, # plot measurement day
#                                   p.remper, # remeasurement period (to nearest 0.1 year)
#                                   p.kindcd, # kind of plot
#                                   p.designcd, # design of plot
#                                   p.rddistcd, # road distance
#                                   p.watercd, # water code
#                                   p.lat, # latitude (note this is the fuzzed and swapped coordinate)
#                                   p.lon, # longitude (note this is the fuzzed and swapped coordinate)
#                                   p.elev, # elevation
#                                   p.p2panel, # p2 panel code
#                                   p.ecosubcd, # ecoregion subdivision code
#                                   p.subp_examine_cd, # subplot code
#                                   p.intensity, # intensity (base intensity = 1)
#                                   p.cycle, # cycle number 
#                                   p.subcycle, # subcycle number
#                                   p.invasive_sampling_status_cd, # invasive species sampling code
#                                   p.designcd_p2a, # design code periodic to annual
#                                   p.manual_db, # database manual version
#                                   p.subpanel, # subpanel
#                                   c.condid, # condition ID
#                                   c.cond_status_cd, # condition status code (1 = forested)
#                                   c.reservcd, # reserve code
#                                   c.owncd, # ownership code
#                                   c.owngrpcd, # owner group code
#                                   c.adforcd, # administrative forest code
#                                   c.fortypcd, # forest type code
#                                   c.stdage, # stand age (estimate)
#                                   c.stdszcd, # stand size code
#                                   c.fldszcd, # field size code
#                                   c.sicond, # site index
#                                   c.sibase, # site index base age
#                                   c.sisp, # site index species code
#                                   c.stdorgcd, # stand origin code
#                                   c.condprop_unadj, # condition proportion
#                                   c.micrprop_unadj, # microplot proportion
#                                   c.subpprop_unadj, # subplot proportion
#                                   c.slope, # slope
#                                   c.aspect, # aspect
#                                   c.physclcd, # physiographic class
#                                   c.dstrbcd1, # disturbance code 1
#                                   c.dstrbyr1, # disturbance year 1
#                                   c.dstrbcd2, # disturbance code 2
#                                   c.dstrbyr2, # disturbance year 2
#                                   c.dstrbcd3, # disturbance code 3
#                                   c.dstrbyr3, # disturbance year 3
#                                   c.trtcd1, # treatment code 1
#                                   c.trtyr1, # treatment year 1
#                                   c.trtcd2, # treatment code 2
#                                   c.trtyr2, # treatment year 2
#                                   c.trtcd3, # treatment code 3
#                                   c.trtyr3, # treatment year 3
#                                   c.balive, # condition basal area for live trees
#                                   c.fldage, # field age
#                                   c.carbon_down_dead, # carbon of dead down trees
#                                   c.carbon_litter, # carbon of litter
#                                   c.carbon_soil_org, # soil carbon
#                                   c.carbon_standing_dead, # dead standing carbon
#                                   c.carbon_understory_ag, # above ground understory carbon
#                                   c.carbon_understory_bg, # below ground understory carbon
#                                   c.harvest_type1_srs, # harvest type 1 (SRS only)
#                                   c.harvest_type2_srs, # harvest type 2 (SRS only)
#                                   c.harvest_type3_srs, # harvest type 3 (SRS only)
#                                   c.stand_structure_srs, # stand structure class (SRS only)
#                                   c.live_canopy_Cvr_pct, # live canopy cover percent
#                                   c.live_missing_canopy_cvr_pct, # live missing canopy cover percent
#                                   c.nbr_live_stems, # number of live stems
#                                   c.siteclcd # site productivity class code
#                                   e.evalid, # evaluation ID to get most recent data
#                                   v.start_invyr, # include EVALID start year
#                                   v.end_invyr, # and ending year
#                                   x.eval_typ # and evaluation type
#               FROM ((((((fs_fiadb.plot p 
#            INNER JOIN fs_fiadb.cond c on p.cn = c.plt_cn)
#           INNER JOIN fs_fiadb.pop_plot_stratum_assgn e on p.cn = e.plt_cn)
#          INNER JOIN fs_fiadb.pop_stratum s on e.stratum_cn = s.cn)
#         INNER JOIN fs_fiadb.pop_estn_unit u on s.estn_unit_cn = u.cn)
#        INNER JOIN fs_fiadb.pop_eval v on u.eval_cn = v.cn)
#       INNER JOIN fs_fiadb.pop_eval_typ x on v.cn = x.eval_cn)
# WHERE p.intensity = '1' # base intensity
# AND p.invyr BETWEEN 1999 and 2019 # from 1999-2019
# AND p.statecd NOT IN (15, 60, 64, 66, 68, 69, 70, 72, 78) # remove territories and HI
# AND x.eval_typ = 'EXPALL' # include all plots
# AND c.cond_status_cd = 1 # from forested land
# AND p.plot_status_cd = 1") # that's measured/accessible forest
# dbDisconnect(con)


### Liz also requested all recent measurements, regardless of if they were
### remeasurements from a previous inventory. There were about 113k plots
### from the last data pull, so hopefully there are a few more.

# We can use the results of the two previous queries and just filter them
# differently, I think.

# NOTE: Texas had different EVALID for west texas, but it shows up if you 
# include 2017 as possible end EVALID year
# plt.sel.tx <- plt.sql %>%
#   filter(STATECD==48) %>%
#   filter(EVAL_TYP %in% c("EXPALL")) %>%
#   filter(END_INVYR>=2017) %>%
#   arrange(END_INVYR) %>%
#   unique()

#rm(list=setdiff(ls(),c("plt.sql","tree.sql", "working_dir", "data_path"))) # because of memory limit issues

### Get the plots from the tree data and figure out their previous measurements

# Read in plot data (if the query hasn't been run yet)
# plt.sql <- readRDS(file.path(data_path, "plot_data.rds"))
# Read in tree data (if the query hasn't been run yet)
# tree.sql <- readRDS(file.path(data_path, "tree_data.rds"))

# Check for duplicates
tree.sql <- tree.sql %>%
  distinct()
plt.sql <- plt.sql %>%
  distinct()

end.evalid <- plt.sql %>% # take the plots
  filter(!PLT_CN %in% PREV_PLT_CN) %>% # only keep it if it hasn't been measured afterward
  select(STATECD, EVALID, START_INVYR, END_INVYR, EVAL_TYP) %>% # select columns
  filter(EVAL_TYP %in% c("EXPALL")) %>% # from EVALIDs for all plots
  group_by(STATECD) %>% # for each state
  #filter(ifelse(STATECD == 48, END_INVYR >= 2017, END_INVYR == max(END_INVYR))) %>% # where the EVALID is from 2017 or after
  distinct() %>% # get unique rows
  arrange(STATECD) # and order by state

prev.plt.cn <- unique(plt.sql$PREV_PLT_CN) # pull previous plot CNs
plt.sel.all <- plt.sql %>% # take all plots
  filter(EVALID %in% end.evalid$EVALID) %>% # only keep the ones from the current evalid
  filter(!PLT_CN %in% prev.plt.cn) # and only if it hasn't been remeasured yet

# Check if there are trees in the plots
tree.sel.all <- tree.sql %>% 
  filter(PLT_CN %in% unique(plt.sel.all$PLT_CN)) # pull only from the current EVALIDs

plt.uq <- unique(tree.sel.all$PLT_CN) # see which plots have trees

plt.sel.info <- plt.sel.all %>% 
  filter(PLT_CN %in% plt.uq) # filter out any that didn't have trees

length(unique(plt.sel.info$CONDID)) # Should be six
length(unique(plt.sel.info$PLT_CN)) # Total number of plots

# Check for spatial distribution (commented out because it goes slow)
plot(LAT~LON, data = plt.sel.info, pch = 19, cex = 0.1, col = scales::alpha("dodgerblue", 0.5))

# Again, get rid of intermediate data for memory sake
#rm(list=setdiff(ls(),c("plt.sql","tree.sql","plt.sel.info", "data_path")))

plt.sql.prev <- plt.sql %>% # Take the plots
  filter(PLT_CN %in% plt.sel.info$PREV_PLT_CN) %>% # find which ones are the previous plot CNs from the current plot CNs
  filter(EVAL_TYP == "EXPALL") # from the all plots evaluation
length(unique(plt.sel.info$PLT_CN)) # now they have the same plots
length(unique(plt.sql.prev$PLT_CN)) # for both measurements

plt.sql.curr <- plt.sel.info %>% 
  filter(PREV_PLT_CN %in% plt.sql.prev$PLT_CN) # Get the current plots
length(unique(plt.sql.curr$PLT_CN)) # now they have the same plots


# Make unique ID code (State_year_number)
unique.plt.sel <- plt.sql.curr %>% # Take the current plots
  select(PLT_CN, PREV_PLT_CN, STATECD, INVYR) %>% # Select columns
  distinct() %>% # keep unique rows
  mutate(plotid = paste(STATECD, INVYR, 1:nrow(.), sep = "_")) # create plot ID

# And create different plotid for the full dataset
rep.na <- plt.sel.info %>% # Take the full plot dataset
  left_join(unique.plt.sel %>% select(PLT_CN, plotid)) %>% # join the plotids to the plots with remeasurements
  filter(is.na(plotid)) %>% # only keep the ones with NA plotid (not in the remeasurements)
  select(PLT_CN, PREV_PLT_CN, STATECD, INVYR) %>% # Select certain columns
  distinct() %>% # get unique rows
  mutate(plotid = paste(STATECD, INVYR, (1:nrow(.) + nrow(unique.plt.sel)), sep = "_")) %>% # create plot ID starting at previous plot ID end value
  bind_rows(unique.plt.sel) %>% # add the remeasurement plot IDs
  select(PLT_CN, PREV_PLT_CN, plotid) %>% # keep just the CN and plotid
  distinct() 

# and join it to the two datasets
plt.sel.cur <- plt.sql.curr %>% 
  left_join(rep.na %>% select(PLT_CN, plotid))

plt.sel.prev <- plt.sql.prev %>%
  left_join(rep.na %>% select(PREV_PLT_CN, plotid), by = c("PLT_CN" = "PREV_PLT_CN"))

# Check that it worked
plt.sel.cur %>% 
  select(plotid) %>%
  distinct() %>%
  left_join(plt.sel.prev %>% select(plotid)) %>%
  distinct() %>%
  nrow()

### Select trees from these two remeasurements

tree.sel.cur <- tree.sql %>% # Current selected trees
  filter(PLT_CN %in% plt.sql.curr$PLT_CN) %>% # But only from this new subset of plots
  left_join(rep.na %>% select(PLT_CN, plotid), by = c("PLT_CN")) # add plotid column

tree.sel.prev <- tree.sql %>% # All trees
  filter(PLT_CN %in% plt.sql.prev$PLT_CN) %>% # But only the previous subset of plots
  left_join(rep.na %>% select(PREV_PLT_CN, plotid), by = c("PLT_CN" = "PREV_PLT_CN")) # add plotid column

# Get all trees from all plots

tree.sel.conus <- tree.sql %>% # full tree sql query
  filter(PLT_CN %in% unique(rep.na$PLT_CN)) %>% # but only from the plots of interest
  distinct() %>% # remove any duplicates
  left_join(rep.na %>% select(PLT_CN, plotid), by = c("PLT_CN")) # and add the plotid 

plt.sel.conus <- plt.sel.info %>% # all plots
  filter(PLT_CN %in% unique(rep.na$PLT_CN)) %>% # get plot cns from the full plot list
  distinct() %>%  # Remove duplicates
  left_join(rep.na %>% select(PLT_CN, plotid), by = c("PLT_CN")) # add plotid

plt.sel.prev %>% # Previous measurements
  left_join(plt.sel.conus %>% select(!PLT_CN)) %>% # join the current all CONUS plots 
  select(plotid) %>% # take plotid
  distinct() %>% # from unique plots
  nrow() # and see how many match


# Export data
# Note, earlier versions of the remeasurement data have a different date code
# and are from all remeasured plots, not just current plots and their previous
# measurement. There will be some plots that are not remeasured recently in those
# earlier datasets... still not sure which will be used in the final analysis.



write.csv(plt.sel.cur, file.path(data_path, "SRSFIA_plots_current_20230519.txt"), row.names = FALSE)
write.csv(plt.sel.prev, file.path(data_path,"SRSFIA_plots_previous_20230519.txt"), row.names = FALSE)
write.csv(tree.sel.cur, file.path(data_path,"SRSFIA_trees_current_20230519.txt"), row.names = FALSE)
write.csv(tree.sel.prev, file.path(data_path,"SRSFIA_trees_previous_20230519.txt"), row.names = FALSE)

# Full CONUS dataset
write.csv(plt.sel.conus, file.path(data_path, "SRSFIA_allplots_20230519.txt"), row.names = FALSE)
write.csv(tree.sel.conus, file.path(data_path, "SRSFIA_alltrees_20230519.txt"), row.names = FALSE)
