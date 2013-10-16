# setwd('/Users/michaelhsu/code/mini_project')
setup_data = read.csv('data/ldpa30_train use.csv')
### further divide into two sets
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

### training data combine # pick bin10 as validation
bin_train = rbind(bin1,bin2,bin3,bin4,bin5,bin6,bin7,bin8,bin9)
bin_train_class1 = subset(bin_train, class == 1)
bin_train_class0 = subset(bin_train, class == 0)
bin_validation = rbind(bin10)

N1 = nrow(bin_train_class1)
N0 = nrow(bin_train_class0)

### pi
pi = matrix(c(N1/(N1+N0),N0/(N1+N0)),ncol=2)
dimnames(pi) = list('pi',c('class1','class0'))

### mean
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

### drop "class"、"new_index" column, calculate covariance matrice
bin_train_class1$class = NULL
bin_train_class1$new_index = NULL
bin_train_class0$class = NULL
bin_train_class0$new_index = NULL

cov_class1 = cov(bin_train_class1)
cov_class0 = cov(bin_train_class0)
cov = (cov_class1 + cov_class1) / (N1+N0)

w  = solve(cov) %*% (mean["class1",] - mean["class0",])
w0_value = ((-0.5) * t(mean["class1",]) %*% solve(cov) %*% mean["class1",]) + (0.5 * t(mean["class0",]) %*% solve(cov) %*% mean["class0",]) + log(pi["pi", "class1"] / pi["pi", "class0"])
w0 = matrix(rep(w0_value),nrow(bin_validation))
### predict
bin_validation_class = bin_validation$class
bin_validation$class = NULL
bin_validation_new_index = bin_validation$new_index
bin_validation$new_index = NULL

logistic_sigmoid <- function(a){
	result = 1/(1+exp(-a))
	result
}

probility_of_class1 = logistic_sigmoid(t(w) %*% t(bin_validation) + t(w0))
bin_validation$probility = t(probility_of_class1)
bin_validation$class = bin_validation_class
bin_validation$class_validation = matrix(rep(0),nrow(bin_validation))

# confusion_matrix
confusion_matrix = matrix(rep(0),ncol=2, nrow=2)
dimnames(confusion_matrix) = list(c("known_class1",'known_class0'), c("prediction_class1",'prediction_class0'))

for (n in 1:nrow(bin_validation)){
	if(bin_validation[n,"probility"] >= 0.5){
		bin_validation[n,"class_validation"] = 1
		if(bin_validation[n,"class"] == 1){
			confusion_matrix["known_class1", "prediction_class1"] = confusion_matrix["known_class1", "prediction_class1"] + 1
		}
		else{
			confusion_matrix["known_class0", "prediction_class1"] = confusion_matrix["known_class0", "prediction_class1"] + 1
		}
	}
	else{
		if(bin_validation[n,"class"] == 1){
			confusion_matrix["known_class1", "prediction_class0"] = confusion_matrix["known_class1", "prediction_class0"] + 1
		}
		else{
			confusion_matrix["known_class0", "prediction_class0"] = confusion_matrix["known_class0", "prediction_class0"] + 1
		}		
	}
}

# performance
performance = matrix(rep(0),ncol=4, nrow=1)
dimnames(performance) = list("class1", c("accuracy",'precision', 'recall', 'F-measure'))

tp = confusion_matrix["known_class1", "prediction_class1"]
fp = confusion_matrix["known_class0", "prediction_class1"]
fn = confusion_matrix["known_class1", "prediction_class0"]
tn = confusion_matrix["known_class0", "prediction_class0"]
performance[, "precision"] = tp / (tp+fp)
performance[, "recall"]    = tp / (tp+fn)
performance[, "accuracy"]  = (tp+tn) / (tp+tn+fp+fn)
performance[, "F-measure"] = 2 * performance[, "precision"] * performance[, "recall"] / (performance[, "precision"]+performance[, "recall"])

# compare NXOR
# TP = sum(!xor(bin_validation['class'],bin_validation['class_validation']))
# TP = sum(bin_validation['class'] & bin_validation['class_validation'])
