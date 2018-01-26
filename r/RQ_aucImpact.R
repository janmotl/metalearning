# Regression analysis AUC for misclassification

library(readxl)


# Mixed regression provides significance estimates for the factors
library(lme4)  # load library
library(lmerTest) # extend lmer with p-value (but has a conflict with merTools)
library(MuMIn) # Get R2
library(merTools) # Model details

ANOVA <- read_excel("Dropbox/Dokumenty/7-1/Predictor Factory/Code/meta learning/RQ_aucImpact.xlsx", sheet = "Data")
fit <- lmer(aucnorm ~ ( 1 | database) + chi2 + runtime + duplication + redundancy + 1, data=ANOVA) 
summary(fit)
plot(fit)
r.squaredGLMM(fit)

feEx <-FEsim(fit, 1000)
reEx <- REsim(fit)
plotFEsim(feEx)
plotREsim(reEx)


## OLS 
fit <- lm(auc ~ database + chi2 + runtime + duplication + redundancy + 1, data=ANOVA) 
summary(fit)
plot(fit)

## Regularized
library(lmmlasso)
lmmlasso(data.matrix(ANOVA[,2:6]), ANOVA$auc)
