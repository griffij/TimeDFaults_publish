# Plot density of multiple runs on one figures

library(ggplot2)
library(ks)
library(lattice)
library(grid)
library(gridExtra)
library(hdrcde)

# Read in posterior dataset
#posterior_files = c('outputs/hyde_eqonly_alpha_unif_1_10_mu_unif_0_150_tpe_lnorm_0.66_16.5/df_posterior_eqonly_1_hyde.csv')
#posterior_files = c('outputs/hyde_alpha_norm_1_0.0625_mu_norm_10_0.0004_tpe_lnorm_0.66_16.5/df_posterior_1_hyde.csv')
#posterior_files = c('outputs/hyde_alpha_unif_0_10_mu_unif_0_150_tpe_lnorm_0.66_16.5/df_posterior_1_hyde.csv')
posterior_files = c('outputs/hyde_eqonly_alpha_norm_1_0.0625_mu_norm_10_0.0004_tpe_lnorm_0.66_16.5/df_posterior_eqonly_1_hyde.csv') 
#posterior_files = c('outputs/df_posterior_eqonly_1_hyde.csv')
#              'outputs/df_posterior_2_hyde.csv')
#MRE_position = c(5,6,6,7)             

plot_posterior_2d <-function(mu, alpha, fig_lab, lab_x=15, lab_y=9.5){
    # Estimate density value containing 95% of posterior ditribution
    # Get mean values
    mean_mu = mean(mu)
    mean_alpha = mean(alpha)
    # Get median
    median_mu = median(mu)
    median_alpha = median(alpha)
    # Get mode
    mode_vals = hdr.2d(mu, alpha, prob=c(1),
           den=NULL, kde.package = c("ks"),
	   h = NULL)
#    print(mode_vals)
    mode = mode_vals$mode
    print('Mode')
    print(mode)
    print('Median')
    cat(median_mu, median_alpha, '\n')
    print('Mean')
    cat(mean_mu, mean_alpha)
    # Here let's add the prior on mu
    xvals = seq(0,150,by=1)
    mu_prior = dnorm(xvals, 10, sqrt(2500))*333
#    mu_prior = dunif(xvals, 0, 150)*333
    # And on alpha
    yvals = seq(0,10,by=0.01)
###    alpha_prior = dnorm(yvals, 1, sqrt(10))*333
    alpha_prior = dnorm(yvals, 1, sqrt(16))*333
#    alpha_prior = dunif(yvals, 0, 10)*333 
    print(yvals)
    print(alpha_prior)
#    alpha_prior = dunif(yvals, 0, 10)*333 
#    print(mu_prior)
    df_mu_prior = data.frame(xvals, mu_prior)
    df_alpha_prior = data.frame(yvals, alpha_prior)
    df_param = data.frame(mu, alpha)
    kd <- ks::kde(df_param, compute.cont=TRUE, positive=TRUE) #1401 gridsize=rep(2001,2) 

    contour_90 =with(kd, contourLines(x=eval.points[[1]], y=eval.points[[2]], 
               z=estimate, levels=cont["10%"])[[1]])
    contour_90 = data.frame(contour_90)
    contour_50 =with(kd, contourLines(x=eval.points[[1]], y=eval.points[[2]],
    	       z=estimate, levels=cont["50%"])[[1]])
    contour_50 = data.frame(contour_50) 
    contour_25 =with(kd, contourLines(x=eval.points[[1]], y=eval.points[[2]],
    	       z=estimate, levels=cont["75%"])[[1]])
    contour_25 = data.frame(contour_25)   
    p1 = ggplot(df_param, aes(x=mu, y=alpha)) +
       	       stat_density_2d(aes(fill = ..density..), geom = "raster", contour = FALSE) +
               geom_path(aes(x=x, y=y), data=contour_90, lwd=0.25) +
               geom_path(aes(x=x, y=y), data=contour_50, lwd=0.5) +
	       geom_path(aes(x=x, y=y), data=contour_25, lwd=0.75) + 
               scale_fill_distiller(palette="Greys", direction=1) +
               labs(colour = "Density") +
               xlab(expression("Mean ("*mu*") (ka)")) +
               ylab(expression("Aperiodicity ("*alpha*")")) +
               scale_x_continuous(expand = c(0, 0), limits = c(0, 150),
	       				 breaks=c(0, 50, 100), labels=c("0", "50", "100")) +
               scale_y_continuous(expand = c(0, 0), limits = c(0, 10), breaks = c(0,2,4,6,8,10),
	       				 labels=c("0","2","4","6","8","10")) +
	       theme(
	           legend.position='none'
  	       )+
	       geom_path(data=df_mu_prior, aes(x = xvals, y = mu_prior), colour='darkorange3') +
	       geom_path(data=df_alpha_prior, aes(x = alpha_prior, y = yvals), colour='darkorange3') +
	       geom_point(x = mean_mu, y=mean_alpha, shape=15, colour='red', size=3) +
	       geom_point(x = median_mu, y=median_alpha, shape=16, colour='blue', size=3) +
	       geom_point(x = mode[1], y=mode[2], shape=17, colour='green', size=3) 
    figname = 'plots/posterior_density_hyde.png'
    return(p1)
    }

labels = c('','a', 'b', 'c', 'd', 'e')
i=1
plot_list <- vector("list", length(posterior_files))
for (filename in posterior_files){
    df_post = read.csv(filename)
    l = paste0(labels[[i]], ')')
    if (i==1){
       mu = df_post$mu
       lambda = df_post$lambda
       y = df_post$mre
       alpha = df_post$alpha
       pl = plot_posterior_2d(mu=mu, alpha=alpha, fig_lab=l)
       plot_list[[i]] = pl
    }else {
       mu = c(mu, df_post$mu)
       lambda = c(lambda, df_post$lambda)
       y = c(y, df_post$mre)
       alpha = c(alpha, df_post$alpha)
       pt = plot_posterior_2d(mu=df_post$mu, alpha=df_post$alpha, fig_lab=l)
       plot_list[[i]] = pt 
       }
#    i = i+1
    }

figname = 'plots/posterior_density_hyde.png'
png(file=figname, units="in", width=4.5, height=5, res=300)
grid.arrange(#pl, pt, nrow=2)
    grobs = plot_list,
    widths=c(0.1,1,0.1),
    layout_matrix = rbind(c(NA, 1, NA))
    )

dev.off()