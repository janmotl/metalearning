# Regression analysis for misclassification

library(readxl)


# Mixed regression provides significance estimates for the factors
library(lme4)  # load library
library(lmerTest) # extend lmer with p-value (but has a conflict with merTools)
library(MuMIn) # Get R2
library(merTools) # Model details

ANOVA <- read_excel("Dropbox/Dokumenty/7-1/Predictor Factory/Code/meta learning/RQ_howManyFeatures.xlsx", sheet = "Data")
fit <- lmer(misclassification ~ ( 1 | database) + attribute + featureFunction + landmarking + 1, data=ANOVA) 
summary(fit)
plot(fit)
r.squaredGLMM(fit)

feEx <-FEsim(fit, 1000)
reEx <- REsim(fit)
plotFEsim(feEx)
plotREsim(reEx)


# OLS 
fit <- lm(misclassification ~ database + attribute + featureFunction + landmarking + 1, data=ANOVA) 
summary(fit)
plot(fit)


