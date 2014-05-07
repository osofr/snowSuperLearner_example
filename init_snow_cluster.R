### init_cluster.R
###
### Script runs through logic to determine whether to set up MPI or socket cluster
### If running locally requires a global variable "processors" to be defined, which specifies the number of cores
###

nHosts <- as.numeric(Sys.getenv('NHOSTS'))
nCores <- as.numeric(Sys.getenv('NSLOTS'))
print("nHosts"); print(nHosts)
print("nCores"); print(nCores)

require(parallel)
require(snow)
require(rlecuyer)

.f_init_cluster <- function(libs, source_fs, clseed) {
  par <- TRUE
  if (is.na(nHosts) || nHosts == 1) { # running locally or on a single host
    runMPIcluster <- FALSE
    # check to see if running locally, so you can grab all cores
    # if (is.na(nCores)) nCores <- processors
    if (is.na(nCores)) nCores <- detectCores()
    cat("running script inside a single node (", nCores, "CPUs) via snow...\n")
    cl <- makeCluster(spec=nCores, type = "SOCK") # use SOCK cluster (local)
  } else {
    runMPIcluster <- TRUE
    require(Rmpi)
    cl <- makeCluster(spec=nCores, type = "MPI") # use MPI cluster (remote)
    cat("running script across", nHosts, "nodes with", nCores, "cores via MPI...\n")
  }
  #set the seed for cluster
  clusterSetRNGStream(cl, iseed = clseed)
  return(list(cl=cl, runMPIcluster=runMPIcluster))
}

# In case R exits unexpectedly, have it automatically clean up
# resources taken up by Rmpi (slaves, memory, etc...)
.Last <- function(){
    if (is.loaded("mpi_initialize")){
        if (mpi.comm.size(1) > 0){
            print("Please use mpi.close.Rslaves() to close slaves.")
            mpi.close.Rslaves()
        }
        print("Please use mpi.quit() to quit R")
        .Call("mpi_finalize")
    }
}
