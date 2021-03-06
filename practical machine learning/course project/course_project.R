library(caret)
library(randomForest)
library(reshape2)

rm(list=ls())
setwd('C:/Users/Leandro/Desktop/Data Science/Course 8 - Practical Machine Learning/course project')

training <- read.csv('pml-training.csv')
testing <- read.csv('pml-testing.csv')

# As primeiras sete colunas s�o dados de identifica��o da pessoa, hora de coleta etc
training <- training[, -c(1:7)]
testing <- testing[, -c(1:7)]


# Exclui as colunas que possuem algum dado igual a NA
training <- training[ , colSums(is.na(training)) == 0]
# Exclui as colunas relativas a kurtosis e skewness
training <- training[, !grepl('kurtosis', names(training))]
training <- training[, !grepl('skewness', names(training))]
# Retira as variaveis que possuem o texto _yaw_belt (existem uns #DIV/0 no conte�do)
training <- training[, !grepl('_yaw_belt', names(training))]
training <- training[, !grepl('_yaw_dumbbell', names(training))]
training <- training[, !grepl('_yaw_forearm', names(training))]


str(training)
dim(training)


# Da base de treinamento, vamos considerar 70% dos dados para treinamento e 30% dos dados para valida��o
set.seed(12345)
inTrain <- createDataPartition(y=training$classe, p=0.7, list=F)
tr <- training[inTrain, ]
validation <- training[-inTrain, ]

# Vamos agora estudar a base de treinamento. Inicialmente, vamos checar se podemos desconsiderar algumas vari�veis
# Para isso, vamos analisar a correla��o entre todas os preditors para verificar se existe alguma vari�vel com
# correla��o pr�xima de 100%. 
# N�o existe uma regra de ouro do que � uma correla��o pr�xima de 100%. Para esse estudo, tendo em vista o elevado
# n�mero de vari�veis de entrada, considerarei que uma correla��o acima de 80% entre as vari�veis �
# suficiente para considerar descartar uma delas.
# Fonte: https://stackoverflow.com/questions/26666533/finding-row-column-names-from-a-correlation-matrix-values

# No total, temos nPreditors preditors (-1 � necess�rio para tirar a classe):
nPreditors <- dim(tr)[2] - 1

# Para encontrar esses valores, n�s temos:
correlationMatrix <- cor(tr[,1:nPreditors])
correlationMatrix[lower.tri(correlationMatrix, diag=TRUE)] <- NA
corGT80percent <- subset(melt(correlationMatrix, na.rm = TRUE), value > 0.8 | value < -0.8)
corGT80percent

# Observando a tabela acima, podemos retirar as seguintes vari�veis:
removeInputs <- unique(as.character(corGT80percent[,2]))
tr <- tr[, -which(names(tr) %in% removeInputs) ]

# Salva o nome das colunas que restaram
cols <- colnames(tr)
# Tira as colunas do conjunto de valida��o que n�o ser�o usadas
validation <- subset(validation, select = names(validation) %in% cols )

mod1 <- randomForest(classe ~., data=tr)

confusionMatrix(predict(mod1, tr), tr$classe)
sum(predict(mod1, tr) == tr$classe)/length(predict(mod1, tr))
confusionMatrix(predict(mod1, validation), validation$classe)
sum(predict(mod1, validation) == validation$classe)/length(predict(mod1, validation))

# Na base de dados de teste, separa apenas as colunas usadas no modelo
testing <- subset(testing, select = names(testing) %in% cols )
predict(mod1, testing)
