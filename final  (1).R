#Final Project
#bankruptcy Classification
#Elaine Guthrie, Adam Schroeder
library(ISLR2)
train_bank <- read.csv("~/Desktop/train.csv", header=TRUE)
dim(train_bank)
summary(train_bank)

# Switch missing values containing "?" with "NA"
idx <- train_bank=="?"
is.na(train_bank) <- idx
sum(is.na(train_bank))
train <- na.omit(train_bank)
dim(train)

# Convert data types
library(dplyr)
names(train)
str(train)
train <- train %>% mutate_if(is.character, as.numeric)
train$class <- as.factor(train$class)
str(train)
train=subset(train, select =-id)
summary(train)


#Visualization

install.packages("graphics")
library(graphics)
plot(train$class,)





install.packages("caret")
library(caret)
featurePlot(x = train[, c("net_profit_plus_depreciation_over_total_liabilities", 
                          "operating_expenses_over_total_liabilities")], 
            y = train$class,
            plot = "density", 
            scales = list(x = list(relation = "free"), 
                          y = list(relation = "free")), 
            adjust = 1.5, 
            pch = "|", 
            layout = c(2, 1), 
            auto.key = list(columns = 2))


install.packages("ellipse")
library(ellipse)
featurePlot(x = train[, c("net_profit_plus_depreciation_over_total_liabilities", 
                          "operating_expenses_over_total_liabilities")], 
            y = train$class, 
            plot = "ellipse",
            auto.key = list(columns = 2))



set.seed(3)
apply(train, 2, var)
train.vis <- subset (train, select = -class)
pcr.out <- prcomp(train.vis , scale = TRUE)
pcr.out$rotation
biplot(pcr.out,scale=0)
(ve=pcr.out$sdev^2)
pve=ve/sum(ve)
round(pve,2)
plot(pcr.out$x[,1:3], pch=19)


#Train & test
train.sample <- sample(1:nrow(train),8000)
bank.test=train[-train.sample,]
train.sample=train[train.sample,]

#logistic regression
library(Metrics)
glm.fits <- glm(
  class ~ ., data = train.sample , family = binomial)
summary(glm.fits)
t=predict(glm.fits,bank.test, type="response")
summary(t)
glm.pred <- ifelse(t > 0.5, "Yes", "No")
table(glm.pred, bank.test$class)
prop.table(table(glm.pred, bank.test$class))

#refined logistic regression
glm.fits <- glm(
  class ~ sales_over_fixed_assets+ total_costs_overtotal_sales+sales_minus_cost_of_products_sold_over_sales
  +short_term_liabilities_over_total_assets+current_assets_minus_inventory_over_short_term_liabilities
  +profit_on_sales_over_sales+constant_capital_over_total_assets
  +operating_expenses_over_short_term_liabilities+operating_expenses_over_total_liabilities
  +net_profit_plus_depreciation_over_total_liabilities+current_assets_over_short_term_liabilities, 
  data = train.sample , family = binomial)
summary(glm.fits)
t=predict(glm.fits,bank.test, type="response")
summary(t)
glm.pred <- ifelse(t > 0.5, "Yes", "No")
table(glm.pred, bank.test$class)
prop.table(table(glm.pred, bank.test$class))


# Classification tree 
library(tree)
attach(train)
set.seed(2)
train.sample=data.frame(train.sample)
tree.bank <- tree(class~., train.sample)
tree.pred <- predict(tree.bank, bank.test, type = "class")
summary(tree.pred)
summary(tree.bank)
plot(tree.pred)
plot(tree.bank)
text(tree.bank, pretty = 0)
(table(tree.pred, bank.test$class))
prop.table(table(tree.pred, bank.test$class))


# Pruning to determine optimal level of tree complexity
set.seed(5)
cv.bank <- cv.tree(tree.bank, FUN = prune.misclass)
names(cv.bank)  
par(mfrow = c(1, 2))  
plot(cv.bank$size, cv.bank$dev, type = "b")  
plot(cv.bank$k, cv.bank$dev, type = "b")  
prune.bank <- prune.misclass(tree.bank, best = 7)
plot(prune.bank)
text(prune.bank, pretty = 0)
prune.pred <- predict(prune.bank, bank.test, type = "class")
table(prune.pred, bank.test$class)
prop.table(table(prune.pred, bank.test$class))

#Bagging
library(randomForest)
set.seed(2)
bag.bank <- randomForest(class~., train.sample,
                         mtry = 65, 
                         importance = TRUE)
bag.bank
yhat= predict(bag.bank, newdata = bank.test, type="class")
table(yhat, bank.test$class)
prop.table(table(yhat, bank.test$class))
importance(bag.bank)



# Random forest
set.seed(3)
rf.bank <- randomForest(class~., train.sample, mtry = 15,
                        importance = TRUE)
yhat.rf <- predict(rf.bank, newdata = bank.test, type="class")
table(yhat.rf, bank.test$class)
importance(rf.bank)
prop.table( table(yhat.rf, bank.test$class))
          
#Boosting
install.packages('gbm')
library(gbm)
install.packages("mlbench")
library(mlbench)
gbm.model = gbm(class~.,train.sample, shrinkage=0.01, 
                distribution = "gaussian",  cv.folds=5,n.trees=5000, interaction.depth = 4)
best.iter = gbm.perf(gbm.model, method="cv")
best.iter
fitControl = trainControl(method="cv", number=5, returnResamp = "all")
model2 = train(class~., data=train.sample, method="gbm",distribution="bernoulli", trControl=fitControl, 
               verbose=F, tuneGrid=data.frame(.n.trees=best.iter, .shrinkage=0.01, .interaction.depth=1, 
                                              .n.minobsinnode=1))

confusionMatrix(model2)


#Using the refined logistic regression model on the test set
test <- read.csv("~/Desktop/test.csv", header=TRUE)
library(dplyr)
names(test)
str(test)
test <- test %>% mutate_if(is.character, as.numeric)
str(test)
summary(test)
dim(test)

idx <- test=="?"
is.na(test) <- idx
sum(is.na(test))
test <- na.omit(test)
dim(test)


prediction= predict(prune.bank, newdata=test, type="class")
class=prediction
testpred= data.frame(test$id, class)
testpred
write.csv(testpred,"~/Desktop/testpredsubmission.csv", row.names = TRUE)