# SchroederAnalystPortfolio
## Project Title
SQL Data Exploration
### Description
In this SQL session, we conduct a basic exploration of Covid-19 data to get more familiar with the data and calculate some basic statistics, such as death rates and infection rates. We also aim to discover potential trends and create tables to later be used to visualize the data. 
## Project Title
Predicting Company Bankruptcy in R
### Description
Using RStudios, we first needed to alter our data to help RStudios interpret our data properly. For example, many numeric fields were stored as strings. Also, missing values were filled with a question mark, which was then replaced by the value "NA" so R could recognize it when calling the na.omit() function. Once this was done, we  then used the company data to predict whether or not that company will go bankrupt in the future.
### Methods
Before creating a predictive model, the first step is to split the data into a training set and a test set. Once we have the data split this way, we can begin working on building a model on the training set. The data used contained over 60 fields, so to filter out some of the predictors that had little to no influence, a classification tree was fit to the training data. A classification tree, when plotted, will actually show which predictors had the most influence. Then, pruning methods were used to determine the optimal level of tree complexity. The accuracy of this model on the test set was compared to other models including GLM, bagging, random forest, and boosting models. The pruned classification model and the random forest model proved to be the best two in terms of predicting bankruptcy on the test set. Each predicted bankruptcy with an accuracy of just above 98%.
