# setwd('/Users/michaelhsu/code/mini_project')
setup_data = read.csv('data/ldpa30_train use.csv')

# further divide into two sets
bin1 = subset(setup_data, new_index > 0    & new_index <= 1110 )
bin2 = subset(setup_data, new_index > 1110 & new_index <= 2220 )
bin3 = subset(setup_data, new_index > 2220 & new_index <= 3330 )
bin4 = subset(setup_data, new_index > 3330 & new_index <= 4440 )
bin5 = subset(setup_data, new_index > 4440 & new_index <= 5550 )
bin6 = subset(setup_data, new_index > 5550 & new_index <= 6660 )
bin7 = subset(setup_data, new_index > 6660 & new_index <= 7770 )
bin8 = subset(setup_data, new_index > 7770 & new_index <= 8880 )
bin9 = subset(setup_data, new_index > 8880 & new_index <= 9990 )
bin10= subset(setup_data, new_index > 9990 & new_index <= 11100)

# training data combine # pick bin10 as validation
bin_train = rbind(bin1,bin2,bin3,bin4,bin5,bin6,bin7,bin8,bin9)
bin_train_class1 = subset(bin_train, class == 1)
bin_train_class0 = subset(bin_train, class == 0)

N1 = nrow(bin_train_class1)
N0 = nrow(bin_train_class0)

# pi
pi = matrix(c(N1/(N1+N0),N0/(N1+N0)),ncol=2)
dimnames(pi) = list('pi',c('class1','class0'))

# mean
mean = matrix(c(rep(0,10)),ncol=5, nrow=2)
dimnames(mean) = list(c("class1",'class0'), c('alpha','beta_mkt','beta_hml','beta_smb','sigma'))
mean["class1","alpha"]    = mean(bin_train_class1$alpha)
mean["class1","beta_mkt"] = mean(bin_train_class1$beta_mkt)
mean["class1","beta_hml"] = mean(bin_train_class1$beta_hml)
mean["class1","beta_smb"] = mean(bin_train_class1$beta_smb)
mean["class1","sigma"]    = mean(bin_train_class1$sigma)

mean["class0","alpha"]    = mean(bin_train_class0$alpha)
mean["class0","beta_mkt"] = mean(bin_train_class0$beta_mkt)
mean["class0","beta_hml"] = mean(bin_train_class0$beta_hml)
mean["class0","beta_smb"] = mean(bin_train_class0$beta_smb)
mean["class0","sigma"]    = mean(bin_train_class0$sigma)

# covariance matrice
cov_class1 = cov(bin_train_class1)
cov_class0 = cov(bin_train_class0)
cov = (cov_class1 + cov_class1) / (N1+N0)