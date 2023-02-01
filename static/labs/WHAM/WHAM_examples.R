## ----setup, include=FALSE-------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ----eval = FALSE---------------------------------------------------------------------------------------------------
## remotes::install_github(repo = 'gmoroncorrea/wham', ref='growth', INSTALL_opts = c("--no-docs", "--no-multiarch", "--no-demo"))


## ----eval = FALSE---------------------------------------------------------------------------------------------------
library(wham)
library(r4ss)
library(ggplot2)
library(TMB)
library(fields)
require(reshape2)


## ----eval = FALSE---------------------------------------------------------------------------------------------------
data_file = r4ss::SS_readdat_3.30(file = 'SS_sim/D4-E0-F0-R0-cod/10/em/ss3.dat') # from EM
SS_report = r4ss::SS_output(dir = 'SS_sim/D4-E0-F0-R0-cod/10/om', covar = FALSE) # from OM
# Define some important information:
min_year = SS_report$startyr
max_year = SS_report$endyr
n_ages = length(1:max(SS_report$agebins))
fish_len = SS_report$lbins
n_years = length(min_year:max_year)


## ----eval = FALSE---------------------------------------------------------------------------------------------------
NAA_SS = SS_report$natage[SS_report$natage$`Beg/Mid` == 'B' & SS_report$natage$Yr >= min_year & SS_report$natage$Yr <= max_year, 14:ncol(SS_report$natage)]
LAA_SS = SS_report$growthseries[SS_report$growthseries$Yr >= min_year & SS_report$growthseries$Yr <= max_year, 6:ncol(SS_report$growthseries)]


## ----eval = FALSE---------------------------------------------------------------------------------------------------
wham_data = list()
wham_data$ages = 1:n_ages
wham_data$lengths = fish_len
wham_data$years = min_year:max_year
wham_data$n_fleets = 1L
wham_data$agg_catch = as.matrix(data_file$catch[2:(n_years+1), 4])
wham_data$catch_cv = as.matrix(data_file$catch[2:(n_years+1), 5])
# Length information fleet:
catch_pal_num = data_file$lencomp[data_file$lencomp$FltSvy == 1, 7:(7+length(wham_data$lengths)-1)]
catch_pal_prop = t(apply(as.matrix(catch_pal_num),1, function(x) x/sum(x)))
wham_data$catch_pal = catch_pal_prop
wham_data$catch_NeffL = as.matrix(as.double(data_file$lencomp[data_file$lencomp$FltSvy == 1, 6]))
wham_data$use_catch_pal = matrix(1, nrow = length(wham_data$years), ncol = wham_data$n_fleets)
wham_data$selblock_pointer_fleets = matrix(1L, ncol = 1, nrow = (max_year - min_year + 1))
wham_data$F = matrix(apply(X = SS_report$fatage[SS_report$fatage$Yr >= min_year &
                                                  SS_report$fatage$Yr <= max_year,
                                                9:ncol(SS_report$fatage)], MARGIN = 1, FUN = max),
                     ncol = 1)
wham_data$n_indices = 1L
wham_data$agg_indices = as.matrix(data_file$CPUE[,4])
# Length information survey
index_pal_num = data_file$lencomp[data_file$lencomp$FltSvy == 2, 7:(7+length(wham_data$lengths)-1)]
index_pal_prop = t(apply(as.matrix(index_pal_num),1, function(x) x/sum(x)))
wham_data$index_pal = array(data = index_pal_prop, dim = c(1, dim(index_pal_prop)[1], dim(index_pal_prop)[2]))
wham_data$index_NeffL =  as.matrix(as.double(data_file$lencomp[data_file$lencomp$FltSvy == 2, 6]))
wham_data$use_index_pal = matrix(1, ncol = 1, nrow = (max_year - min_year + 1))

wham_data$index_cv = as.matrix(data_file$CPUE[,5])
wham_data$units_indices = rep(0L, times = 1) # numbers
wham_data$selblock_pointer_indices = matrix(2L, ncol = 1, nrow = (max_year - min_year + 1))
wham_data$fracyr_indices = matrix(0.01, ncol = 1, nrow = (max_year - min_year + 1))
wham_data$maturity = matrix(rep(SS_report$endgrowth[2:(n_ages+1),19], times = max_year - min_year + 1),
                            ncol = n_ages, nrow = max_year - min_year + 1, byrow = TRUE)
wham_data$fracyr_SSB = rep(0, times = max_year - min_year + 1)
wham_data$Fbar_ages = 4L:20L
wham_data$percentSPR = 40
wham_data$percentFXSPR = 100
wham_data$percentFMSY = 100
wham_data$XSPR_R_avg_yrs = 1:n_years
wham_data$XSPR_R_opt = 2
wham_data$simulate_period = c(1,0)
wham_data$bias_correct_process = 1
wham_data$bias_correct_observation = 1


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_input1 = prepare_wham_input(model_name="whamGrowth1",
                               selectivity=list(model=rep("age-specific",2),
                                                re=rep("none",2),
                                                initial_pars=list(c(rep(0, 3), rep(1, 17)),
                                                                  c(rep(1, 20))),
                                                fix_pars = list(1:20, 1:20),
                                                n_selblocks = 2),
                              M = list(model = 'constant', re = 'none',
                                       initial_means = 0.36),
                              NAA_re = list(sigma="rec", cor = 'iid', N1_model = 0,
                                            recruit_model = 2,
                                            N1_pars = as.vector(as.matrix(NAA_SS[1,])),
                                            recruit_pars = c(300000)),
                              growth = list(model = 'vB_classic',
                                            re = c('none', 'iid_y', 'none'),
                                            init_vals = c(0.16, 117.9, 19.8),
                                            SD_vals = c(2, 11)),
                              LW = list(init_vals = c(5.58883e-006, 3.18851)),
                              catchability = list(re = 'none', initial_q = 1, q_lower = 0,
                                                  q_upper = 1000, prior_sd = NA),
                              basic_info = wham_data)


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_input1$par$log_NAA = as.matrix(log(NAA_SS[-1,])) # set initial rec devs as OM
my_input1$par$mean_rec_pars = mean(log(NAA_SS[,1])) # mean recruitment as OM
my_input1$map$log_N1_pars = factor(rep(NA, times = n_ages)) # fix N1
my_input1$map$log_F1 = factor(c(NA)) # fix F1
my_input1$map$logit_q = factor(NA) # fix q


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_model_1 = fit_wham(my_input1, do.osa = FALSE, do.fit = TRUE, do.retro = FALSE, n.newton = 0)
check_convergence(my_model_1)


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_input2 = prepare_wham_input(model_name="whamGrowth2",
                               selectivity=list(model=rep("age-specific",2),
                                                re=rep("none",2),
                                                initial_pars=list(c(rep(0, 3), rep(1, 17)),
                                                                  c(rep(1, 20))),
                                                fix_pars = list(1:20, 1:20),
                                                n_selblocks = 2),
                              M = list(model = 'constant', re = 'none',
                                       initial_means = 0.36),
                              NAA_re = list(sigma="rec", cor = 'iid', N1_model = 0,
                                            recruit_model = 2,
                                            N1_pars = as.vector(as.matrix(NAA_SS[1,])),
                                            recruit_pars = c(300000)),
                              LAA = list(LAA_vals = as.vector(as.matrix(LAA_SS[1,])),
                                         re = c('iid'), SD_vals = c(2, 11)),
                              LW = list(init_vals = c(5.58883e-006, 3.18851)),
                              catchability = list(re = 'none', initial_q = 1, q_lower = 0,
                                                  q_upper = 1000, prior_sd = NA),
                              basic_info = wham_data)


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_input2$par$log_NAA = as.matrix(log(NAA_SS[-1,])) # set initial rec devs as OM
my_input2$par$mean_rec_pars = mean(log(NAA_SS[,1])) # mean recruitment as OM
my_input2$map$log_N1_pars = factor(rep(NA, times = n_ages)) # fix N1
my_input2$map$log_F1 = factor(c(NA)) # fix F1
my_input2$map$logit_q = factor(NA) # fix q


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_model_2 = fit_wham(my_input2, do.osa = FALSE, do.fit =TRUE, do.retro = FALSE, n.newton = 0)
check_convergence(my_model_2)


## ----eval = FALSE---------------------------------------------------------------------------------------------------
envindex = read.csv('SS_sim/aux_files/PDO_annual_1970_2019.csv')
envindex = envindex[envindex$years >= min_year & envindex$years <= max_year, ]
# Create ecov object:
ecov <- list(
  label = "PDO",
  mean = as.matrix(envindex$index),
  logsigma = 'est_1',
  year = envindex$years,
  use_obs = matrix(1, ncol=1, nrow=dim(envindex)[1]),
  lag = 0,
  ages = list(1:n_ages),
  process_model = 'ar1',
  where = 'growth',
  where_subindex = 2, # Linf
  how = 0)


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_input3 = prepare_wham_input(model_name="whamGrowth3",
                               selectivity=list(model=rep("age-specific",2),
                                                re=rep("none",2),
                                                initial_pars=list(c(rep(0, 3), rep(1, 17)),
                                                                  c(rep(1, 20))),
                                                fix_pars = list(1:20, 1:20),
                                                n_selblocks = 2),
                              ecov = ecov,
                              M = list(model = 'constant', re = 'none',
                                       initial_means = 0.36),
                              NAA_re = list(sigma="rec", cor = 'iid', N1_model = 0,
                                            recruit_model = 2,
                                            N1_pars = as.vector(as.matrix(NAA_SS[1,])),
                                            recruit_pars = c(300000)),
                              growth = list(model = 'vB_classic',
                                            re = c('none', 'none', 'none'),
                                            init_vals = c(0.16, 117.9, 19.8),
                                            SD_vals = c(2, 11)),
                              LW = list(init_vals = c(5.58883e-006, 3.18851)),
                              catchability = list(re = 'none', initial_q = 1, q_lower = 0,
                                                  q_upper = 1000, prior_sd = NA),
                              basic_info = wham_data)


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_input3$par$log_NAA = as.matrix(log(NAA_SS[-1,])) # set initial rec devs as OM
my_input3$par$mean_rec_pars = mean(log(NAA_SS[,1])) # mean recruitment as OM
my_input3$map$log_N1_pars = factor(rep(NA, times = n_ages)) # fix N1
my_input3$map$log_F1 = factor(c(NA)) # fix F1
my_input3$map$logit_q = factor(NA) # fix q


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_model_3 = fit_wham(my_input3, do.osa = FALSE, do.fit =TRUE, do.retro = FALSE)
check_convergence(my_model_3)


## ----eval = FALSE, include=FALSE------------------------------------------------------------------------------------
## my_model_1 = readRDS('my_model_1.rds')
## my_model_2 = readRDS('my_model_2.rds')
## my_model_3 = readRDS('my_model_3.rds')


## ----eval = FALSE---------------------------------------------------------------------------------------------------
all_models = list(my_model_1,my_model_2,my_model_3)
dir.create('growth_models')
compare_wham_models(all_models, fdir = 'growth_models', do.table = FALSE)


## ----echo = FALSE, eval=FALSE---------------------------------------------------------------------------------------
## # Prepare data:
## LAA_SS = as.matrix(LAA_SS)
## rownames(LAA_SS) = min_year:(max_year-1)
## data_0 = setNames(reshape2::melt(LAA_SS), c('year', 'age', 'LAA'))
## data_0$age = data_0$age
## data_0$type = 'OM'
## 
## LAA_data_1 = my_model_1$rep$LAA
## rownames(LAA_data_1) = min_year:max_year
## colnames(LAA_data_1) = 1:n_ages
## data_1 = setNames(reshape2::melt(LAA_data_1), c('year', 'age', 'LAA'))
## data_1$type = 'iid_y Linf'
## 
## LAA_data_2 = my_model_2$rep$LAA
## rownames(LAA_data_2) = min_year:max_year
## colnames(LAA_data_2) = 1:n_ages
## data_2 = setNames(reshape2::melt(LAA_data_2), c('year', 'age', 'LAA'))
## data_2$type = 'iid LAA'
## 
## LAA_data_3 = my_model_3$rep$LAA
## rownames(LAA_data_3) = min_year:max_year
## colnames(LAA_data_3) = 1:n_ages
## data_3 = setNames(reshape2::melt(LAA_data_3), c('year', 'age', 'LAA'))
## data_3$type = 'Ecov Linf'
## #Merge data:
## plot_data = rbind(data_0, data_1, data_2, data_3)
## 
## # Plot:
## ggplot(data = plot_data, aes(x = year, y = LAA, color = factor(type))) +
##   geom_line() +
##   theme_bw() +
##   labs(color = 'Model') +
##   theme(legend.position = c(0.6, 0.1), legend.direction="horizontal") +
##   facet_wrap(. ~ factor(age), nrow = 5, scales = 'free_y')


## ----eval = FALSE---------------------------------------------------------------------------------------------------
data_file = r4ss::SS_readdat_3.30(file = 'SS_sim/D6-E0-F0-R0-cod/10/em/ss3.dat') # from EM
SS_report = r4ss::SS_output(dir = 'SS_sim/D6-E0-F0-R0-cod/10/om', covar = FALSE) # from OM
# Define some important information:
min_year = SS_report$startyr
max_year = SS_report$endyr
n_ages = length(1:max(SS_report$agebins))
fish_len = SS_report$lbins
n_years = length(min_year:max_year)


## ----eval = FALSE---------------------------------------------------------------------------------------------------
NAA_SS = SS_report$natage[SS_report$natage$`Beg/Mid` == 'B' & SS_report$natage$Yr >= min_year & SS_report$natage$Yr <= max_year, 14:ncol(SS_report$natage)]


## ----eval = FALSE---------------------------------------------------------------------------------------------------
wham_data = list()
wham_data$ages = 1:n_ages
wham_data$lengths = fish_len
wham_data$years = min_year:max_year
wham_data$n_fleets = 1L
wham_data$n_indices = 1L
wham_data$agg_catch = as.matrix(data_file$catch[2:(n_years+1), 4])
wham_data$catch_cv = as.matrix(data_file$catch[2:(n_years+1), 5])
catch_pal_num = data_file$lencomp[data_file$lencomp$FltSvy == 1, 7:(7+length(wham_data$lengths)-1)]
catch_pal_prop = t(apply(as.matrix(catch_pal_num),1, function(x) x/sum(x)))
wham_data$catch_pal = catch_pal_prop
wham_data$catch_NeffL = as.matrix(as.double(data_file$lencomp[data_file$lencomp$FltSvy == 1, 6]))
wham_data$use_catch_pal = matrix(1, nrow = length(wham_data$years), ncol = wham_data$n_fleets)
wham_data$agg_indices = as.matrix(data_file$CPUE[,4])
wham_data$index_cv = as.matrix(data_file$CPUE[,5])
wham_data$units_indices = rep(0L, times = 1) # numbers
wham_data$fracyr_indices = matrix(0, ncol = 1, nrow = (max_year - min_year + 1))
# -------------------------------------------------------------------------
# index CAAL information (Neff):
index_alk_Neff = array(0, dim = c(length(wham_data$years), wham_data$n_fleets, length(wham_data$lengths)))
all_years_lengths = expand.grid(Lbin_lo = wham_data$lengths, Yr = wham_data$years)
alk_info = data_file$agecomp[data_file$agecomp$FltSvy == 2, ] # for survey
temp1 = dplyr::left_join(all_years_lengths, alk_info, c("Lbin_lo", 'Yr'))
temp2 = reshape2::dcast(temp1, Yr ~ Lbin_lo, value.var = 'Nsamp')
temp2[is.na(temp2)] = 0
index_alk_Neff[,1,] = as.matrix(temp2[,-1])
wham_data$index_caal_Neff = index_alk_Neff
# -------------------------------------------------------------------------
# index CAAL information (use/not use):
useCAAL = array(0, dim = dim(wham_data$index_caal_Neff))
useCAAL[which(wham_data$index_caal_Neff > 0)] = 1
wham_data$use_index_caal = useCAAL
# -------------------------------------------------------------------------
# index CAAL:
index_alk = array(0, dim = c(wham_data$n_indices, length(wham_data$years), length(wham_data$lengths), length(wham_data$ages)))
all_years_lengths = expand.grid(Lbin_lo = wham_data$lengths, Yr = wham_data$years)
alk_info = data_file$agecomp[data_file$agecomp$FltSvy == 2, ]
temp1 = dplyr::left_join(all_years_lengths, alk_info, c("Lbin_lo", 'Yr'))
for(i in seq_along(wham_data$years)) {

  tmpData = temp1[temp1$Yr == wham_data$years[i], 11:(10+n_ages)]
  tmpData = t(apply(as.matrix(tmpData),1, function(x) x/sum(x))) # prop
  tmpData[is.na(tmpData)] = 0
  index_alk[1,i,,] = as.matrix(tmpData)

}
wham_data$index_caal = index_alk
# -------------------------------------------------------------------------
wham_data$selblock_pointer_indices = matrix(2L, ncol = 1, nrow = (max_year - min_year + 1))
wham_data$selblock_pointer_fleets = matrix(1L, ncol = 1, nrow = (max_year - min_year + 1))
wham_data$F = matrix(apply(X = SS_report$fatage[SS_report$fatage$Yr >= min_year &
                                                  SS_report$fatage$Yr <= max_year,
                                                9:ncol(SS_report$fatage)], MARGIN = 1, FUN = max),
                     ncol = 1)
wham_data$maturity = matrix(rep(SS_report$endgrowth[2:(n_ages+1),19], times = max_year - min_year + 1),
                            ncol = n_ages, nrow = max_year - min_year + 1, byrow = TRUE)
wham_data$fracyr_SSB = rep(0, times = max_year - min_year + 1)
wham_data$Fbar_ages = c(5L,20L)
wham_data$percentSPR = 40
wham_data$percentFXSPR = 100
wham_data$percentFMSY = 100
wham_data$XSPR_R_avg_yrs = 1:n_years
wham_data$XSPR_R_opt = 2
wham_data$simulate_period = c(1,0)
wham_data$bias_correct_process = 1
wham_data$bias_correct_observation = 1


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_input4 = prepare_wham_input(model_name="Ex_Selectivity_CAAL",
                              selectivity=list(model=c("len-double-normal","len-logistic"),
                                               re=rep("none",2),
                                               initial_pars=list(c(45,0.7,-1,1,-6,-6),
                                                                 c(15,3)),
                                               fix_pars = list(2:6, 2),
                                               n_selblocks = 2),
                              M = list(model = 'constant', re = 'none',
                                       initial_means = 0.36),
                              NAA_re = list(sigma="rec", cor = 'iid', N1_model = 0,
                                            recruit_model = 2,
                                            N1_pars = as.vector(as.matrix(NAA_SS[1,])),
                                            recruit_pars = c(300000)),
                              growth = list(model = 'vB_classic',
                                            re = c('none', 'none', 'none'),
                                            init_vals = c(0.16, 117.9, 19.8),
                                            est_pars = 1, # estimate K
                                            SD_vals = c(2, 11)),
                              LW = list(init_vals = c(5.58883e-006, 3.18851)),
                              catchability = list(re = 'none', initial_q = 1, q_lower = 0,
                                                  q_upper = 1000, prior_sd = NA),
                              basic_info = wham_data)


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_input4$par$log_NAA = as.matrix(log(NAA_SS[-1,])) # set initial rec devs as OM
my_input4$par$mean_rec_pars = mean(log(NAA_SS[,1])) # mean recruitment as OM
my_input4$map$log_N1_pars = factor(rep(NA, times = n_ages)) # fix N1
my_input4$map$log_F1 = factor(c(NA)) # fix F1
my_input4$map$logit_q = factor(NA) # fix q


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_model_4 = fit_wham(my_input4, do.osa = FALSE, do.fit =FALSE, do.retro = FALSE, n.newton = 0)
check_convergence(my_model_4)

my_model_4$rep[grep('nll',names(my_model_4$rep))] %>% lapply(sum) %>% unlist

## ----eval = FALSE, include=FALSE------------------------------------------------------------------------------------
## my_model_4 = readRDS('my_model_4.rds')


## ----eval = FALSE---------------------------------------------------------------------------------------------------
## dir.create(path = 'my_model_4')
## plot_wham_output(mod = my_model_4, dir.main = 'my_model_4', res = 300, out.type = 'png')


## ----eval = FALSE---------------------------------------------------------------------------------------------------
data_file = r4ss::SS_readdat_3.30(file = 'SS_sim/D7-E0-F0-R0-cod/10/em/ss3.dat') # from EM
SS_report = r4ss::SS_output(dir = 'SS_sim/D7-E0-F0-R0-cod/10/om', covar = FALSE) # from OM
# Define some important information:
min_year = SS_report$startyr
max_year = SS_report$endyr
n_ages = length(1:max(SS_report$agebins))
fish_len = SS_report$lbins
n_years = length(min_year:max_year)


## ----eval = FALSE---------------------------------------------------------------------------------------------------
NAA_SS = SS_report$natage[SS_report$natage$`Beg/Mid` == 'B' & SS_report$natage$Yr >= min_year & SS_report$natage$Yr <= max_year, 14:ncol(SS_report$natage)]


## ----eval = FALSE---------------------------------------------------------------------------------------------------
wham_data = list()
wham_data$ages = 1:n_ages
wham_data$lengths = fish_len
wham_data$years = min_year:max_year
wham_data$n_fleets = 1L
wham_data$agg_catch = as.matrix(data_file$catch[2:(n_years+1), 4])
wham_data$catch_cv = as.matrix(data_file$catch[2:(n_years+1), 5])
# Length information fleet
catch_pal_num = data_file$lencomp[data_file$lencomp$FltSvy == 1, 7:(7+length(wham_data$lengths)-1)]
catch_pal_prop = t(apply(as.matrix(catch_pal_num),1, function(x) x/sum(x)))
wham_data$catch_pal = catch_pal_prop
wham_data$catch_NeffL = as.matrix(as.double(data_file$lencomp[data_file$lencomp$FltSvy == 1, 6]))
wham_data$use_catch_pal = matrix(1, nrow = length(wham_data$years), ncol = wham_data$n_fleets)
wham_data$selblock_pointer_fleets = matrix(1L, ncol = 1, nrow = (max_year - min_year + 1))
wham_data$F = matrix(apply(X = SS_report$fatage[SS_report$fatage$Yr >= min_year &
                                                  SS_report$fatage$Yr <= max_year,
                                                9:ncol(SS_report$fatage)], MARGIN = 1, FUN = max),
                     ncol = 1)
wham_data$n_indices = 1L
wham_data$agg_indices = as.matrix(data_file$CPUE[,4])
index_paa_num = data_file$agecomp[data_file$agecomp$FltSvy == 2, 11:(10+n_ages)]
index_paa_prop = t(apply(as.matrix(index_paa_num),1, function(x) x/sum(x)))
wham_data$index_paa = array(data = index_paa_prop, dim = c(1,max_year-min_year+1,n_ages))
wham_data$index_cv = as.matrix(data_file$CPUE[,5])
wham_data$index_Neff =  as.matrix(as.double(data_file$agecomp[data_file$agecomp$FltSvy == 2, 9]))
wham_data$units_indices = rep(0L, times = 1) # numbers
wham_data$units_index_paa = rep(2L, times = 1) # numbers
wham_data$use_index_paa = matrix(1, ncol = 1, nrow = (max_year - min_year + 1))
wham_data$selblock_pointer_indices = matrix(2L, ncol = 1, nrow = (max_year - min_year + 1))
wham_data$fracyr_indices = matrix(0, ncol = 1, nrow = (max_year - min_year + 1))
# Observed weight-at-age:
waa_matrix = as.matrix(SS_report$wtatage[SS_report$wtatage$Fleet == -1 &
                                           SS_report$wtatage$Yr <= max_year, 8:(7+n_ages)])
waa_matrix_ini = as.matrix(SS_report$wtatage[SS_report$wtatage$Fleet == 0 &
                                               SS_report$wtatage$Yr <= max_year, 8:(7+n_ages)])
waa_tot_matrix = rbind(waa_matrix, waa_matrix_ini, waa_matrix, waa_matrix_ini)
dim(waa_tot_matrix) = c(max_year-min_year+1,4,n_ages)
waa_tot_matrix2 = aperm(waa_tot_matrix, c(2,1,3))
wham_data$waa = waa_tot_matrix2
# Add CV and turnon likelihood for waa:
wham_data$waa_cv = array(0, dim = dim(wham_data$waa))
wham_data$waa_cv[1:2,,] = 0.1
wham_data$use_index_waa = matrix(1L, ncol = wham_data$n_indices, nrow = n_years)
wham_data$use_catch_waa = matrix(1L, ncol = wham_data$n_fleets, nrow = n_years)
# Continue..
wham_data$maturity = matrix(rep(SS_report$endgrowth[2:(n_ages+1),19], times = max_year - min_year + 1),
                            ncol = n_ages, nrow = max_year - min_year + 1, byrow = TRUE)
wham_data$fracyr_SSB = rep(0, times = max_year - min_year + 1)
wham_data$Fbar_ages = c(5L,20L)
wham_data$percentSPR = 40
wham_data$percentFXSPR = 100
wham_data$percentFMSY = 100
wham_data$XSPR_R_avg_yrs = 1:n_years
wham_data$XSPR_R_opt = 2
wham_data$simulate_period = c(1,0)
wham_data$bias_correct_process = 1
wham_data$bias_correct_observation = 1


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_input5 = prepare_wham_input(model_name="Ex_LW",
                              selectivity=list(model=rep("age-specific",2),
                                               re=rep("none",2),
                                               initial_pars=list(c(rep(0, 3), rep(1, 17)),
                                                                 c(rep(1, 20))),
                                               fix_pars = list(1:20, 1:20),
                                               n_selblocks = 2),
                              M = list(model = 'constant', re = 'none',
                                       initial_means = 0.36),
                              NAA_re = list(sigma="rec", cor = 'iid', N1_model = 0,
                                            recruit_model = 2,
                                            N1_pars = as.vector(as.matrix(NAA_SS[1,])),
                                            recruit_pars = c(300000)),
                              growth = list(model = 'vB_classic',
                                            re = c('none', 'none', 'none'),
                                            init_vals = c(0.16, 117.9, 19.8),
                                            SD_vals = c(2,11)),
                              catchability = list(re = 'none', initial_q = 1, q_lower = 0,
                                                  q_upper = 1000, prior_sd = NA),
                              LW = list(re = c('ar1_y', 'none'),
                                        init_vals = c(5.58883e-06, 3.18851)),
                              basic_info = wham_data)


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_input5$par$log_NAA = as.matrix(log(NAA_SS[-1,])) # set initial rec devs as OM
my_input5$par$mean_rec_pars = mean(log(NAA_SS[,1])) # mean recruitment as OM
my_input5$map$log_N1_pars = factor(rep(NA, times = n_ages)) # fix N1
my_input5$map$log_F1 = factor(c(NA)) # fix F1
my_input5$map$logit_q = factor(NA) # fix q


## ----eval = FALSE---------------------------------------------------------------------------------------------------
my_model_5 = fit_wham(my_input5, do.osa = FALSE, do.fit =TRUE, do.retro = FALSE)
check_convergence(my_model_5)


## ----eval = FALSE, include=FALSE------------------------------------------------------------------------------------
## my_model_5 = readRDS('my_model_5.rds')


## ----eval = FALSE---------------------------------------------------------------------------------------------------
## dir.create(path = 'my_model_5')
## plot_wham_output(mod = my_model_5, dir.main = 'my_model_5', res = 300, out.type = 'pdf')


## ----echo = FALSE, eval = FALSE-------------------------------------------------------------------------------------
## parameter_variability = read.csv('SS_sim/D7-E0-F0-R0-cod/Growth_parameters.csv')
## plot_data = data.frame(years = rep(min_year:max_year, times = 2),
##                        par_a = c(parameter_variability$WtLen1, my_model_5$rep$LW_par[,1,1]),
##                        type = rep(c('OM', 'WHAM'), each = n_years))
## # Plot:
## ggplot(data = plot_data, aes(x = years, y = par_a, color = factor(type))) +
##   geom_line() +
##   theme_bw() +
##   labs(color = 'Model') +
##   theme(legend.direction="horizontal", legend.position = 'bottom')

