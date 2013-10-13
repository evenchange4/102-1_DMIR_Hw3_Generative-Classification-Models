setup_data = read.csv('data/ldpa30_train.csv')

# further divide into two sets
Set1 = subset(setup_data, week_index <= 270)
Set2 = subset(setup_data, week_index > 270)
N1 = nrow(Set1)
N2 = nrow(Set2)