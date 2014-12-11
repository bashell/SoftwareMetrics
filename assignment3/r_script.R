library(fBasics)
library(pROC)
library(psych)
library(MASS)
mydata <- read.csv("c:\\Users\\lenovo\\Desktop\\metrics.csv")  #读入数据框

cat("描述性统计:")
print(summary(mydata[, 3:9]))

# 去掉数据框的前两列
mydata <- mydata[, -1]
mydata <- mydata[, -1]

cat("偏度:")
print(skewness(mydata))
cat("峰度:")
print(kurtosis(mydata))

cat("spearman相关系数:")
print(cor(mydata, method="spearman"))
cat("pearson相关系数:")
print(cor(mydata, method="pearson"))

cat("spearman统计显著性:")
print(corr.test(mydata, method="spearman"))
cat("pearson统计显著性:")
print(corr.test(mydata, method="pearson"))

# logistic回归
fit.full <- glm(mydata$Bug ~ CountLineCode + CountPath + Cyclomatic + MaxNesting + Knots + CountInput + CountOutput, data = mydata)
print(summary(fit.full))
# 特征选择后，重新建立模型
fit.reduced <- glm(mydata$Bug ~ CountLineCode + CountPath + Cyclomatic + Knots + CountOutput, data = mydata)
print(summary(fit.reduced))


# 计算分类性能(AUC)
mydata_auc <- auc(mydata[,8], mydata[,1] + mydata[,2] + mydata[,3] + mydata[,5] + mydata[,7])
cat("预测模型的AUC:", mydata_auc)

# 计算排序性能(CE)
y <- mydata[,8] / 74
temp <- 0
bug_len <- length(mydata[,8])
for(i in 1: bug_len){
  temp <- temp + y[i]
  y[i] <- temp
}
total_area <- 0
for(i in 1: (bug_len - 1)){
  area <- (y[i] + y[i + 1]) / bug_len / 2
  total_area <- total_area + area
}
mydata_ce <- (mydata_auc - 0.5)/ (total_area - 0.5)
cat("预测模型的CE:", mydata_ce)


#***************直接使用CountLineCode进行分类或者排序***************
CountLineCode_auc = auc(mydata[,8], mydata[,1])
y <- mydata[,8] / 74
temp <- 0
bug_len <- length(mydata[,8])
for(i in 1: bug_len){
  temp <- temp + y[i]
  y[i] <- temp
}
total_area <- 0
for(i in 1: (bug_len - 1)){
  area <- (y[i] + y[i + 1]) / bug_len / 2
  total_area <- total_area + area
}
CountLineCode_ce <- (CountLineCode_auc - 0.5) / (total_area - 0.5)
cat("直接使用CountLineCode时：")
cat("AUC:", CountLineCode_auc)
cat("CE:", CountLineCode_ce)


#***************检验在统计上是否有显著差别***********************
print(t.test(mydata[,1], mydata[,1] + mydata[,2] + mydata[,3] + mydata[,5] + mydata[,7], paired=TRUE))

