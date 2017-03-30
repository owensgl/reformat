#Based on script by Eric C. Anderson.
#Updated for tped data by Gregory L. Owens


#####Usage
#Rscript ./tped2missingdata.R input.tped output.tped
#####Required libraries
library(dplyr)

####VARIABLES
AI <- c(5) #alpha_I shape parameter for gamma distribution over individuals
AL <- c(5) #alpha_L shape parameter for gamma distribution over loci
A <- 10 #desired average read depth at a locus in an individual
min_reads <- 6 #Minimum number of simulated reads to call a SNP

###ARGUMENTS
args = commandArgs(trailingOnly=TRUE)
if (!length(args)==2) {
  stop("You must supply two arguments: an input tped file and output tped file name", call.=FALSE)
} 
#' function to return read depths for individuals at different loci
#'
#' This version conditions on total read depth. Note that the scale
#' parameters get set according to the desired number of reads, but that
#' is just so that there won't likely be underflow (and it should make it 
#' easier to do a version that does not condition on the total number of reads,
#' later.)
#' @param N total number of individuals desired
#' @param L total number of loci desired
#' @param A desired average read depth at a locus in an individual
#' @param alpha_I shape parameter for gamma distribution over individuals
#' @param alpha_L shape parameter for gamma distribution over loci
read_depths_func <- function(N = 100,
                             L = 4000,
                             A = 10,
                             alpha_I,
                             alpha_L) {
  
  # get the desired average number of reads per individual
  ra_ind <- A * L
  
  
  # simulate the number of reads per individual. Note that this is 
  # one way to simualate a compound Dirichlet-multinomial.  (Simulate
  # the Dirichlet as a bunch of gammas scaled by their sum, and then
  # set that as the cell probs in a multinomial.)
  # the scale is set here only so things are large enough that there
  # is not a likely chance of underflow
  tmp <- rgamma(n = N, shape = alpha_I, scale = N * L * A / alpha_I)  
  tmp <- tmp / sum(tmp)
  nreads <- rmultinom(n = 1, size = N * L * A, prob = tmp)[, 1]
  
  names(nreads) <- paste(1:N, sep = "")  # give each individual some names
  
  # then simulate the number of reads per locus within each individual. For this 
  # we can use a CDM, and bind it altogether into a tidy data frame.  We want
  # each locus to have its own characteristic rate at which reads come off of it,
  # so we simulate those first, and then use those to apportion reads from each individual
  loc_gammas <- rgamma(n = L, shape = alpha_L, scale = 100 / alpha_L)
  loc_dirichlet <- loc_gammas / sum(loc_gammas)  # a dirichlet r.v. is a vector of gammas with common scale (scaled to sum to one)
  
  lapply(nreads, function(x) {
    if(x > 0) {
      r <- rmultinom(n = 1, size = x, prob = loc_dirichlet)[, 1]
    } else {
      r <- rep(0, length(loc_dirichlet))
    }
    dplyr::data_frame(locus = paste(1:L, sep = ""), nreads = r)
  }) %>%
    dplyr::bind_rows(., .id = "indiv")
}


#Load in tped data
data <- read.table(args[1],header=F)
N <- (ncol(data[1,]) - 4) /2
L <- nrow(data)
set.seed(5)

names(AI) <- AI
names(AL) <- AL
read_depths <- lapply(AI, function(ai) {
  lapply(AL, function(al) {
    read_depths_func(N, L, A, ai, al)
  }) %>%
    bind_rows(., .id = "alpha_loc")
}) %>% bind_rows(., .id = "alpha_ind")

read_depths <- read_depths %>% mutate(isMissing = nreads < min_reads)
new_data <- data
for (i in 1:L){
  for (j in 1:N){
    line <- (N * (j-1))+i
    if(read_depths$isMissing[line]){
      new_data[i,((j*2)+4)] <- "0"
      new_data[i,((j*2)+3)] <- "0"
    }
  }
}
write.table(new_data, file=args[2],col.names = F,row.names = F,quote=F)
