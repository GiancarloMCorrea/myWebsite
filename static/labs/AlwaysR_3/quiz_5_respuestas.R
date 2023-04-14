
# Respuestas a Quiz 5 -----------------------------------------------------

# Repaso Pregunta 1

mod1 = lmer(normexam ~ standLRT + (1 | school), data = Exam)
mod2 = lmer(normexam ~ standLRT + (0 +  standLRT| school), data = Exam)
mod3 = lmer(normexam ~ standLRT + (1 +  standLRT| school), data = Exam)
AIC(mod1)
AIC(mod2)
AIC(mod3)

# Repaso Pregunta 2

mod3 = lmer(normexam ~ standLRT + (1 +  standLRT| school), data = Exam)
plot(ggeffects::ggpredict(mod3, terms = c("standLRT", "school [1,2,3]"), type = 'random'))

# Modelos lineales generalizados Pregunta 1

mod1 = glm(breaks ~ wool + tension, data = warpbreaks, family = poisson)

# Modelos lineales generalizados Pregunta 2

mod2 = glm(breaks ~ wool + tension, data = warpbreaks, family = quasipoisson)

# Modelos lineales generalizados Pregunta 3

qqnorm(qresid(mod2))
qqline(qresid(mod2))

# Modelos aditivos generalizados Pregunta 1

mod1 = gam(O3 ~ s(temp) + s(ibh), data = ozone)
summary(mod1)

# Modelos aditivos generalizados Pregunta 2

plot(ggpredict(mod1), facets = TRUE)

# Modelos aditivos generalizados Pregunta 3

mod1 = gam(O3 ~ s(temp) + s(ibh), data = ozone)
mod2 = gam(O3 ~ s(temp) + ibh, data = ozone)
summary(mod1)
summary(mod2)
