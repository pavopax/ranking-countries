source("../header.R")                      #source functions and load packages
source("functions.R")

## usn: 60 usn countries
## all: all countries
## full: countries and regions
usn0 <- read.csv("../../cache/latest_usn.csv", stringsAsFactors=FALSE,
                row.names=1) %>% tbl_df
all0 <- read.csv("../../cache/latest_all.csv", stringsAsFactors=FALSE,
                row.names=1) %>% tbl_df
full0 <- read.csv("../../cache/latest_full.csv", stringsAsFactors=FALSE,
                row.names=1) %>% tbl_df
classes <- read.csv("../../cache/classes.csv", stringsAsFactors=FALSE,
                row.names=1) %>% tbl_df
attrs <- read.csv("../../cache/attrs.csv", stringsAsFactors=FALSE,
                  row.names=1) %>% tbl_df
codes <- read.csv("../../cache/codes.csv", stringsAsFactors=FALSE,
                  row.names=1) %>% tbl_df

## make data for this program
usn_feats <- attrs %>% select(Indicator, usn_feat) %>% na.omit() %>%
    filter(usn_feat==1) %>% .$Indicator


names(usn0) %<>% tolower

usn.wide <- usn0 %>% left_join(., codes, by="indicator") %>%
    select(country, indicator, label_short, zscore_) %>%
    filter(indicator %in% usn_feats) %>% select(-indicator) 

%>%
    spread(label_short, zscore_) 


%>%
    mutate_each(funs(na.zero(.)))

## back from wide to long to include imputed values for each indicator
usn1 <- usn.wide %>% gather("Indicator", "zscore_", -1)



## ============================================================================
## Explore
## ============================================================================
## # of indicators by country. max = 38
usn0 %>% group_by(Country) %>% tally %>% arrange(n)

## amazing
## https://cran.r-project.org/web/packages/corrplot/vignettes/corrplot-intro.html
library(corrplot)                       

dat <- usn.wide
M <-  cor(dat[,-1])

png("../../output/tmp_2-corrs.png", width=800, height=800)
corrplot(M, method="ellipse", order="FPC")
dev.off()


## what is each country good at? ... bad at? 
nn <- 5
usn1 %>% group_by(Country) %>%  top_n(., nn) %>% ungroup() %>%
    arrange(desc(zscore_))

usn1 %>% group_by(Country) %>% arrange(zscore_)  %>% slice(1:nn) %>%
    ungroup() %>% arrange(zscore_)


## all indicators hers
my.indics <- names(usn.wide)[-1]
my_indicators <- attrs %>% filter(Indicator %in% my.indics) %>%
    select(Group, Attribute, Indicator, Label) 

write_my_csv("my_indicators")



## ============================================================================
## Rank them by summing zscores
## ============================================================================
## by average

ranked <- usn.wide %>% mutate(zmean=rowMeans(.[-1])) %>% arrange(desc(zmean))
rank1 <- ranked %>% select(Country, zmean) %>%
    mutate(score2=100*round(zmean,2)) %>% select(-zmean) %>% as.data.frame
names(rank1) <- c("Country", "Score (0=average)")
write_my_csv("rank1")


## by summing
ranked <- usn.wide %>% mutate(zsum=rowSums(.[-1])) %>% arrange(desc(zsum))
ranked %>% select(Country, zsum) %>% as.data.frame






## ============================================================================
## PCA
## ============================================================================

## USN

## TODO: use zscore here!
usnX1 <- usn1 %>% spread(Indicator, zscore_) 
usnX <- usnX1 %>% select(-Country)

pca <- princomp(usnX[,-1], cor=T)
summary(pca)
#loadings(pca)

predicts <- predict(pca)

png("../../output/pca_country2.png", width=800, height=800)
plot(predicts[,1], predicts[,2], type="n",
     xlab="Component 1", ylab="Component 2")
text(predicts[,1], predicts[,2], usnX1$Country,)
title(main="Which countries are similar?")
dev.off()     

theme_set(theme_bw())
dat <- as.data.frame(predicts)

p1 <- ggplot(dat, aes(x=dat[,1], y=dat[,2], label=usnX1$Country)) +
    geom_text(size=3) + labs(x="Component 1", y="Component 2") +
    xlim(c(-5,8))
ggsave("../../output/ggpca1.png", p1, width=7, height=5)

library(ggfortify)


p <- ggplot(aes(x=

autoplot(pca, labels=usnX1$Country)

library(ggbiplot)
#library(scales)
g <- ggbiplot(pca, obs.scale = 1, var.scale = 1
              #groups = usnX1$Country,
              ellipse = TRUE, 
              circle = TRUE)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal', 
               legend.position = 'top')
g

## barplot(pca$sdev)
## screeplot(pca)

## REGION
## X2 <- left_join(usnX1, classes, by="Country")
## X <- X2[,2:22]

## pca <- princomp(X, cor=T)
## summary(pca)
## #loadings(pca)

## predicts <- predict(pca)

## png("../../plots/pca_region.png", width=800, height=800)
## plot(predicts[,1], predicts[,2], type="n",
##      xlab="Component 1", ylab="Component 2")
## text(predicts[,1], predicts[,2], X2$Region)
## title(main="Which countries are similar?")
## dev.off()     




## ALL COUNTIRES

x1 <- all %>% select(-Year) %>% spread(Series.Code, Value) 
X <- X1 %>% select(-Country)
pca <- princomp(X[,-1], cor=T)
summary(pca)
##loadings(pca)


predicts <- predict(pca)
plot(predicts[,1], predicts[,2])
text(predicts[,1], predicts[,2], X1$Country)

screeplot(pca)
plot(pca)


## ============================================================================
## CLASSIFICATION
## ============================================================================
library(class)                          #knn
library(psych)                          #tr()
library(MASS)                           #lda()

usnX1 <- usn.std %>% dplyr::select(-Value) %>% spread(Series.Code, zscore_) 

df0 <- left_join(usnX1, classes, by="Country")

##xx <- sample(1:60, 40)
train <- df0[xx,] %>% dplyr::select(-Country)
test <- df0[-xx,] %>% dplyr::select(-Country)


## error: cross-validation
tem1 <- tem2 <- err1.train <- err1.cv <- err1.test <- 0
kk <- 10
for(i in 1:kk){
  knns <- knn.cv(train[,-c(22,23)],cl=train$Region,k=i,prob=FALSE)
  tem1 <- table(train$Region,knns)
  err1.cv[i] <- (sum(tem1)-tr(tem1))/sum(tem1)
}
plot(err1.cv,type='l')  


## error: train
## training error should be =0 when K=1
for(i in 1:kk){
  knns <- knn(train[,-c(22,23)],train[,-c(22,23)],cl=train$Region,k=i,prob=TRUE)
  tem1 <- table(train$Region,knns)
  err1.train[i] <- (sum(tem1)-tr(tem1))/sum(tem1)
}
plot(err1.train)

## error: test
for(i in 1:kk){
  knns <- knn(train[,-c(22,23)],test[,-c(22,23)],cl=train$Region,k=i,prob=TRUE)
  tem1 <- table(test$Region,knns)
  err1.test[i] <- (sum(tem1)-tr(tem1))/sum(tem1)
}
plot(err1.test)

## plot ALL errors
err1.all <- as.data.frame(c(err1.cv,err1.test,err1.train))
err1.all$index <- as.factor(rep(c(1:kk),3))
err1.all$error <- as.factor(c(rep("cv",length(err1.cv)),rep("test",length(err1.test)),rep("train",length(err1.train))))
names(err1.all) <- c("val","index","error")
#err.all[c(1:10,90:120,190:205,299,300),]

qplot(index,val,data=err1.all,geom="line",group=error,colour=error)+
  scale_x_discrete(breaks=seq(0,50,5))+labs(x="K",y="error value")

p50 <- ggplot(data=err1.all, aes(x=index,y=val)) + geom_point(size=2,aes(shape=error))+geom_line(aes(group=error, colour=error))+scale_x_discrete(breaks=seq(0,50,5))+
  labs(x="K",y="error value")
p50





## ============================================================================
## TARGET: REGION
## ============================================================================

## LDA
df <- df0 %>% dplyr::select(-Country, -Income.Group)
##xx <- sample(1:60, 40)
train <- df[xx,]
test <- df[-xx,]

(usn.lda <- lda(Region ~ .,data=df))

## error: training
preds1 <- predict(usn.lda, train[,1:21])
res1 <- table(train$Region, preds1$class)
missclass_rate(res1)

## error: testing
preds2 <- predict(usn.lda, test[,1:21])
res2 <- table(test$Region, preds2$class)
missclass_rate(res2)

eqscplot(preds1$x,type='n',xlab='First LD',ylab='Second LD')
text(x=preds1$x[,1],y=preds1$x[,2],labels=train$Region)








## ============================================================================
## TARGET: INCOME GROUP
## ============================================================================
df <- df0 %>% dplyr::select(-Country, -Region)
##xx <- sample(1:60, 40)
train <- df[xx,]
test <- df[-xx,]

(usn.lda <- lda(Income.Group ~ .,data=df))

## error: training
preds1 <- predict(usn.lda, train[,1:21])
res1 <- table(train$Income.Group, preds1$class)
missclass_rate(res1)

## error: testing
preds2 <- predict(usn.lda, test[,1:21])
res2 <- table(test$Income.Group, preds2$class)
missclass_rate(res2)

eqscplot(preds1$x,type='n',xlab='First LD',ylab='Second LD')
text(x=preds1$x[,1],y=preds1$x[,2],labels=train$Income.Group)












