

#setwd("/Users/threeprime/Documents/Dropbox/NIMBioS END/extinctions/Analysis") Jimmy
# setwd("/Users/piresmm/Dropbox/NIMBioS Working Group/extinctions/Analysis") #Mathias
setwd("/Users/threeprime/Dropbox/NIMBioS_END/extinctions/Analysis") #Jimmy
# setwd("/Users/piresmm/Dropbox/NIMBioS Working Group/extinctions/Analysis") #Mathias

data_dir <- file.path("..", "Data")
fig_dir <- file.path("..", "Figures")

source("functions/coextDeg_beta.R")
source("functions/coextNumber_beta.R")
source("functions/netcascade.R")

# suggested beta distribution parameters:
# 0.1 and 1 gives exponential-like distribution;
# 0.5 and 1 gives Pareto-like ("power-law") distribution
# 1 and 1 give uniform-like distribution
# 8 and 8 give normal-like distribution
# 4 and 0.1 give a left skewed distribution
# 0.2 and 0.2 give a bimodal distribution

beta.par <- matrix(c(0.1, 1, 0.5, 1, 1, 1, 3, 3, 4, 0.1, 0.2, 0.2), byrow = TRUE, ncol = 2)
rownames(beta.par)=c("exp","power","unif","normal","left", "bimod")

pdf(file = "R_input_beta.pdf")
par(mfrow=c(3,2)) #, mar=c(1,1,1,1)
for(i in 1:nrow(beta.par)){
	hist(rbeta(1000, beta.par[i,1], beta.par[i,2]), main = rownames(beta.par)[i], xlab = "R")
}
dev.off()
#Computes the cascade degree and extinction numbers for each matrix 
#Different parameter combinations (bet.par)
#All species have the same initial probability of initial extinction

# path to directory containing empirical networks:
emp_net_path <- file.path(data_dir, "nets_emp")

# load all networks in that directory
emp_nets<-dir(path = emp_net_path) #Plant-pollinator weighted nets

#Testing different nets
list.net.deg<-list()
list.net.numb<-list()

mat_empirical <- list()

for(p in 1:length(emp_nets)){
	mat_empirical[[p]] <- as.matrix(read.table(file.path(emp_net_path, emp_nets[p])))
}

sapply(lapply(mat_empirical, rowSums), min)
# mat_empirical[[4]] <- NULL
length(mat_empirical)

for(p in 1:length(mat_empirical)){

  mat <- mat_empirical[[p]]

  if(min(c(rowSums(mat), colSums(mat))) == 0){
    stop("Hey, you have a species in your network that does not interact with any other species. The following functions will get stuck.")}
  
  m<-nrow(mat)
  n<-ncol(mat)

  list.deg<-list()
  list.numb<-list()
  for(k in 1:nrow(beta.par)){
  	
    #storing results for each parameter combination
    list.deg[[k]] <- coextDeg_beta(imatrix = mat, nsims = 1000, beta_par1_T1 = beta.par[k,1], beta_par2_T1 = beta.par[k,2],beta_par1_T2 = beta.par[k,1], beta_par2_T2 = beta.par[k,2])
    list.numb[[k]] <- coextNumber_beta(imatrix = mat, nsims = 1000, beta_par1_T1 = beta.par[k,1], beta_par2_T1 = beta.par[k,2],beta_par1_T2 = beta.par[k,1], beta_par2_T2 = beta.par[k,2])
  }
  
  #storing results for each net
  list.net.deg[[p]]<-list.deg 
  list.net.numb[[p]]<-list.numb
}

#------------------
#Plotting results
#------------------

q=8#choose net
Temp.deg<-list.net.deg[[q]]
Temp.numb<-list.net.numb[[q]]
Temp.numb <- lapply(Temp.numb,log)

par(mfrow = c(2,1), mar=c(3,4,2,2))
boxplot(Temp.deg[[1]],Temp.deg[[2]],Temp.deg[[3]],Temp.deg[[4]],Temp.deg[[5]], main="Degree", col="darkgray")
boxplot(Temp.numb[[1]],Temp.numb[[2]],Temp.numb[[3]],Temp.numb[[4]],Temp.numb[[5]],main="Number",col="darkgray")
axis(1, at=1:5, label=rownames(beta.par))


#Results
#Changing the distributions have small effects
#The likelihood of large cascades only increase for left skewed distribuition of R

#To do
#1.Targeted extinctions (JO)
#2.Look at the topological role of secondarily extinct spp. (JO - output extinct species)
#3.Analyze the topology of resulting networks (JO - output the resulting nets)

# Code for analyzing species (species strength,degree, centrality, contribution to nestedness, R) and networks (asymmetry, strength distrib,nestedness,modularity, fractioning analysis) (MMP)

#4.What happens if distributions are different for plants and pollinators?
#5.Measure the number of extinctions of plants and animals separately

#Random weighted net
# let m be the number of species in Trophic level 1
m <- 10
# let n be the number of species in Trophic level 2
n <- 5
mat <- matrix(rbinom(100,10,0.1),m,n)
if(min(c(rowSums(mat), colSums(mat))) == 0)
  stop("Hey, you have a species in your network that does not interact with any other species. The following functions will get stuck.")




#pdf(file = "R_from_beta.pdf")

par(mfrow = c(2,3))
hist(list.deg[[1]], xlab = "degree", main = "beta(1,1) 'uniform'", ylim = c(0,1000))
hist(list.deg[[2]], xlab = "degree", main = "beta(0.1,1) 'exponential'", ylim = c(0,1000))
hist(list.deg[[3]], xlab = "degree", main = "beta(3,3) 'normal'", ylim = c(0,1000))
hist(list.deg[[4]], xlab = "number", main = "beta(1,1) 'uniform'", ylim = c(0,1000))
hist(list.deg[[5]], xlab = "number", main = "beta(0.1,1) 'exponential'", ylim = c(0,1000))

par(mfrow = c(2,3))
hist(list.numb[[1]], xlab = "degree", main = "beta(1,1) 'uniform'", ylim = c(0,1000))
hist(list.numb[[2]], xlab = "degree", main = "beta(0.1,1) 'exponential'", ylim = c(0,1000))
hist(list.numb[[3]], xlab = "degree", main = "beta(3,3) 'normal'", ylim = c(0,1000))
hist(list.numb[[4]], xlab = "number", main = "beta(1,1) 'uniform'", ylim = c(0,1000))
hist(list.numb[[5]], xlab = "number", main = "beta(0.1,1) 'exponential'", ylim = c(0,1000))


#dev.off()

