# Respuestas Quiz 4 -------------------------------------------------------

# Repaso Pregunta 1

mod1 = lm(Petal.Length ~ Sepal.Length + Sepal.Width, data = iris)

# Repaso Pregunta 2

mod1 = lm(Petal.Length ~ Sepal.Length + Sepal.Width, data = iris)
plot(mod1, which = 2)

# Repaso Pregunta 3

mod1 = lm(Petal.Length ~ Sepal.Length + Sepal.Width, data = iris)
mySummary = summary(mod1)
mySummary$adj.r.squared
mySummary$sigma

# Interacciones Pregunta 1

mod2 = lm(Petal.Length ~ Sepal.Length*Species, data = iris)
AIC(mod2)
BIC(mod2)

# Interacciones Pregunta 2

mod2 = lm(Petal.Length ~ Sepal.Length*Species, data = iris)
plot_model(mod2, type = 'int')

# Interacciones Pregunta 3
mod3 = lm(hipcenter ~ ., data = seatpos)
test = olsrr::ols_step_forward_p(model = mod3, penter = 0.05, progress = FALSE)
summary(test$model)

# Efectos aleatorios Pregunta 1

mod4 = lme4::lmer(Petal.Length ~ Sepal.Length + (0 + Sepal.Length | Species), data = iris)

# Efectos aleatorios Pregunta 2

mod4 = lme4::lmer(Petal.Length ~ Sepal.Length + (0 + Sepal.Length | Species), data = iris)
coef(mod4)$Species

# Efectos aleatorios Pregunta 3

# Ninguna / Ambas
