#measures the time needed for "deploy_rf_variant.R" and "deploy_rf_pkg.R"

sys.time.seq <- system.time(source("deploy_rf_variant.R"))
#result: sys.time.seq
#User      System verstrichen 
#1.22        0.03        1.25 
sys.time.seq <- system.time(source("deploy_rf_pkg.R"))
#result:sys.time.seq
#User      System verstrichen 
#0.00        0.03        0.03 



system.time(post.df.to.server(d.test[1,-785], "localhost:8000/predictempty"))
#result:  
#User      System verstrichen 
#0.14        0.00        0.46 
system.time(post.df.to.server(d.test[1,-785], "localhost:8000/predictsmall"))
#result:
#User      System verstrichen 
#0.25        0.00        0.61 
system.time(post.df.to.server(d.test[1,-785], "localhost:8000/predictlarge"))
#result:
#User      System verstrichen 
#0.08        0.00        0.64 

system.time(post.df.to.server(d.test[1,-785], "localhost:8000/predictemptypkg"))
#User      System verstrichen 
#0.08        0.02        0.35 
system.time(post.df.to.server(d.test[1,-785], "localhost:8000/predictsmallpkg"))
#User      System verstrichen 
#0.08        0.00        0.37 
system.time(post.df.to.server(d.test[1,-785], "localhost:8000/predictlargepkg"))
#User      System verstrichen 
#0.06        0.00        0.51 