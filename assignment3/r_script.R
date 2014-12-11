library(fBasics)
library(pROC)
library(psych)
library(MASS)
mydata <- read.csv("c:\\Users\\lenovo\\Desktop\\metrics.csv")  #�������ݿ�

cat("������ͳ��:")
print(summary(mydata[, 3:9]))

# ȥ�����ݿ��ǰ����
mydata <- mydata[, -1]
mydata <- mydata[, -1]

cat("ƫ��:")
print(skewness(mydata))
cat("���:")
print(kurtosis(mydata))

cat("spearman���ϵ��:")
print(cor(mydata, method="spearman"))
cat("pearson���ϵ��:")
print(cor(mydata, method="pearson"))

cat("spearmanͳ��������:")
print(corr.test(mydata, method="spearman"))
cat("pearsonͳ��������:")
print(corr.test(mydata, method="pearson"))

# logistic�ع�
fit.full <- glm(mydata$Bug ~ CountLineCode + CountPath + Cyclomatic + MaxNesting + Knots + CountInput + CountOutput, data = mydata)
print(summary(fit.full))
# ����ѡ������½���ģ��
fit.reduced <- glm(mydata$Bug ~ CountLineCode + CountPath + Cyclomatic + Knots + CountOutput, data = mydata)
print(summary(fit.reduced))


# �����������(AUC)
mydata_auc <- auc(mydata[,8], mydata[,1] + mydata[,2] + mydata[,3] + mydata[,5] + mydata[,7])
cat("Ԥ��ģ�͵�AUC:", mydata_auc)

# ������������(CE)
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
cat("Ԥ��ģ�͵�CE:", mydata_ce)


#***************ֱ��ʹ��CountLineCode���з����������***************
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
cat("ֱ��ʹ��CountLineCodeʱ��")
cat("AUC:", CountLineCode_auc)
cat("CE:", CountLineCode_ce)


#***************������ͳ�����Ƿ����������***********************
print(t.test(mydata[,1], mydata[,1] + mydata[,2] + mydata[,3] + mydata[,5] + mydata[,7], paired=TRUE))
