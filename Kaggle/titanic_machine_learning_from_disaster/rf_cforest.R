train<-read.csv("./data/train.csv",na.strings=c('NA',''),stringsAsFactors=F)
test<-read.csv("./data/test.csv",na.strings=c('NA',''),stringsAsFactors=F)

#loading libraries
library(randomForest)
library(party)
library(rpart)
# library(rattle)

#checking the missing data
check.missing<-function(x) return(paste0(round(sum(is.na(x))/length(x),4)*100,'%'))
data.frame(sapply(train,check.missing))
data.frame(sapply(test,check.missing))

#combine train/test data for pre-processing
train$Cat<-'train'
test$Cat<-'test'
test$Survived<-NA
full<-rbind(train,test)

#Embarked
table(full$Embarked)
#  C   Q   S 
#270 123 914 
# subset(full, is.na(Embarked)) -> Google -> "S"...
full$Embarked[is.na(full$Embarked)]<-'S'

#Extract Title from Name
full$Title<-sapply(full$Name,function(x) strsplit(x,'[.,]')[[1]][2])
full$Title<-gsub(' ','',full$Title)
aggregate(Age~Title,full,median)
full$Title[full$Title %in% c('Capt', 'Don', 'Major', 'Sir')] <- 'Sir'
full$Title[full$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] <- 'Lady'

#check the result
aggregate(Age~Title,full,summary, digits=2)
#         Title Age.Min. Age.1st Qu. Age.Median Age.Mean Age.3rd Qu. Age.Max.
#1          Col    47          52         54       54          57       60   
#2           Dr    23          38         49       44          52       54   
#3         Lady    38          38         39       42          44       48   
#4       Master    0.33        2          4        5.50        9       14   
#5         Miss    0.17        15         22       22          30       63   
#6         Mlle    24          24         24       24          24       24   
#7          Mme    24          24         24       24          24       24   
#8           Mr    11          23         29       32          39       80   
#9          Mrs    14          27         36       37          46       76   
#10          Ms    28          28         28       28          28       28   
#11         Rev    27          30         42       41          52       57   
#12         Sir    40          45         49       51          52       70   
#13 theCountess    33          33         33       33          33       33   

#Adding FamilySize
full$FamilySize<-full$Parch+full$SibSp+1

#Fare
# create a decision tree for Fare based on Pclass+Title+Sex+SibSp+Parch (1 Passenger)
fit.Fare<-rpart(Fare[!is.na(Fare)]~Pclass+Title+Sex+SibSp+Parch,data=full[!is.na(full$Fare),],method='anova')
# display the results
printcp(fit.Fare) 
# fancyRpartPlot(fit.Fare, main="Fare decision tree - overkill, predicting the 1 single missing Fare")
#predict(fit.Fare,full[is.na(full$Fare),])
#    1044 
#12.08246 
#> summary(full$Fare)
#
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#  0.000   7.896  14.450  33.300  31.280 512.300       1 
full$Fare[is.na(full$Fare)]<-predict(fit.Fare,full[is.na(full$Fare),])

#FamilyId2
Surname<-sapply(full$Name,function(x) strsplit(x,'[.,]')[[1]][1])
FamilyId<-paste0(full$FamilySize,Surname)
full$FamilyId<-factor(FamilyId)
Family<-data.frame(table(FamilyId))
SmallFamily<-Family$FamilyId[Family$Freq<=2]
FamilyId[FamilyId %in% SmallFamily]<-'Small'
full$FamilyId2<-factor(FamilyId)

#Age decision tree (regression) method to predict the 20.09% missing Age data
fit.Age<-rpart(Age[!is.na(Age)]~Pclass+Title+Sex+SibSp+Parch+Fare,data=full[!is.na(full$Age),],method='anova')
# fancyRpartPlot(fit.Age, main="Age decision tree - predict the 20.09% missing Age data")
full$Age[is.na(full$Age)]<-predict(fit.Age,full[is.na(full$Age),])

#Adding Mother
full$Mother<-0
full$Mother[full$Sex=='female' & full$Parch>0 & full$Age>18 & full$Title!='Miss']<-1
#Adding Child
full$Child<-0
full$Child[full$Parch>0 & full$Age<=18]<-1

#check missing 
data.frame(sapply(full,check.missing))

#Exact Deck from Cabin number
full$Deck<-sapply(full$Cabin, function(x) strsplit(x,NULL)[[1]][1])
deck.fit<-rpart(Deck~Pclass+Fare,data=full[!is.na(full$Deck),])
full$Deck[is.na(full$Deck)]<-as.character(predict(deck.fit,full[is.na(full$Deck),],type='class'))
full$Deck[is.na(full$Deck)]<-'UNK'

#Excat Position from Cabin number
full$CabinNum<-sapply(full$Cabin,function(x) strsplit(x,'[A-Z]')[[1]][2])
full$num<-as.numeric(full$CabinNum)
num<-full$num[!is.na(full$num)]
Pos<-kmeans(num,3)
full$CabinPos[!is.na(full$num)]<-Pos$cluster
full$CabinPos<-factor(full$CabinPos)
levels(full$CabinPos)<-c('Front','End','Middle')
full$num<-NULL
#side.train<-full[!is.na(full$Side),]
#side.test<-full[is.na(full$Side),]
#side.fit<-rpart(Side~FamilyId+FamilySize,side.train,method='class')
#full$Side[is.na(full$Side)]<-as.character(predict(side.fit,side.test,type='class'))

#factorize the categorical variables
full<-transform(full,
                Pclass=factor(Pclass),
                Sex=factor(Sex),
                Embarked=factor(Embarked),
                Title=factor(Title),
                Mother=factor(Mother),
                Child=factor(Child),
                FamilyId2=factor(FamilyId2),
                Deck=factor(Deck)
                )

#split train/test data
train<-full[full$Cat=='train',]
test<-full[full$Cat=='test',]
train$Survived<-factor(train$Survived)


#cforest (conditional inference tree) method, (support variables with more levels and missing values, with unbiased prediction)
fit.cf<-cforest(Survived~FamilyId2+CabinPos+Deck+Pclass+Sex+Age+SibSp+Parch+Fare+Embarked+Title+Mother+Child+Deck,data=train,controls=cforest_unbiased(ntree=500, mtry=3))

#write submission
test$Survived<-predict(fit.cf,test,OOB=TRUE,type='response')
submission<-test[,1:2]
write.csv(submission,'submission_cforest.csv',row.names=F)
