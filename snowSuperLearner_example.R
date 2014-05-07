rm(list=ls())

# DON NOT USE:
# install.packages("/Users/olegsofrygin/Dropbox/AWS_starcluster_R/subsemble/subsemble_0.0.5.tar.gz", repos = NULL, type="source")
# library(subsemble)

#------------------------------------------------------------
## Example of parallel SuperLearner with snow on mpi cluster
#------------------------------------------------------------

library(SuperLearner)
library(parallel)
library(snow)
library(rlecuyer)


#------------------------------------------------------------
# SET-UP THE CLUSTER (returns cluster object "cl")
#------------------------------------------------------------
# processors <- 1 # (only used when running locally on OS X)
clseed <- 2343
source("init_snow_cluster.R")
# list any packages you need loaded on the nodes:
# package_nms <- c("SuperLearner")
# source_nms <- ""
cluster_list <- .f_init_cluster(package_nms, source_nms, clseed)
runMPIcluster <- cluster_list$runMPIcluster
cl <- cluster_list$cl
cat("runMPIcluster=", runMPIcluster, "\n")


#------------------------------------------------------------
# SIMULATE SOME DATA:
#------------------------------------------------------------
## training set
n <- 1000
p <- 50
X <- matrix(rnorm(n*p), nrow = n, ncol = p)
colnames(X) <- paste("X", 1:p, sep="")
X <- data.frame(X)
Y <- X[, 1] + sqrt(abs(X[, 2] * X[, 3])) + X[, 2] - X[, 3] + rnorm(n)

## test set
m <- 1000
newX <- matrix(rnorm(m*p), nrow = m, ncol = p)
colnames(newX) <- paste("X", 1:p, sep="")
newX <- data.frame(newX)
newY <- newX[, 1] + sqrt(abs(newX[, 2] * newX[, 3])) + newX[, 2] - newX[, 3] + rnorm(m)


#------------------------------------------------------------
# RUN SUPER LEARNER IN PARALLEL (ON SIMULATED DATA)
#------------------------------------------------------------
# generate Library and run Super Learner
SL.library <- c("SL.glm", "SL.randomForest", "SL.gam", 
  "SL.polymars", "SL.mean")

# PARALLEL SUPERLEARNER (DOESN'T RUN)
testSNOW <- snowSuperLearner(cluster = cl, Y = Y, X = X, newX = newX, SL.library = SL.library, method = "method.NNLS")
testSNOW

# REGURULAR SUPERLEARNER (RUNS)
testSL <- SuperLearner(Y = Y, X = X, newX = newX, SL.library = SL.library, method = "method.NNLS")
testSL

#------------------------------------------------------------
# STOP THE CLUSTER:
#------------------------------------------------------------
stopCluster(cl)
if (runMPIcluster) mpi.quit()



