# Regression analysis ofKIs

library(readxl)

# Regression on aggregated values (delivers overly optimistic R2)
R <- read_excel("Dropbox/Dokumenty/7-1/Predictor Factory/Code/meta learning/RQ_factorAnalysis.xlsx", sheet = "Averaged")
fit <- lm(ki ~ chi2 + duplication + runtime + duplication:chi2 + 0, data=R) 
summary(fit)


# ANOVA treats blocks as a random variable, not as fixed effects.
ANOVA <- read_excel("Dropbox/Dokumenty/7-1/Predictor Factory/Code/meta learning/RQ_factorAnalysis.xlsx", sheet = "Data")
fit <- aov(ki ~ database + chi2 + duplication + runtime + duplication:chi2, data=ANOVA) 
summary(fit)


# Mixed regression provides significance estimates for the factors
library(lme4)  # load library
library(lmerTest) # extend lmer with p-value
library(MuMIn) # Get R2

ANOVA <- read_excel("Dropbox/Dokumenty/7-1/Predictor Factory/Code/meta learning/RQ_factorAnalysis.xlsx", sheet = "Data")
fit <- lmer(ki ~ ( 1 | database) + chi2 + duplication + runtime + duplication:chi2 + 1, data=ANOVA) 
summary(fit)
plot(fit)
r.squaredGLMM(fit)



