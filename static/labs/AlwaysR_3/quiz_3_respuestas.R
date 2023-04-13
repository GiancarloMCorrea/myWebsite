
# Respuestas Quiz 3 -------------------------------------------------------

# Repaso: Pregunta 1

#Kolmogorov-Smirnov / Prueba Z / greater

# Repaso: Pregunta 2

t.test(x = USArrests$Rape, alternative = 'less', mu = 18)

# Repaso: Pregunta 3

binom.test(x = 43, n = 150, p = 0.4, alternative = 'less')

# Modelos lineales: Pregunta 1

mod1 = lm(Murder ~ Rape + Assault, data = USArrests)
summary(mod1)

# Modelos lineales: Pregunta 2
mod1 = lm(Murder ~ Rape + Assault, data = USArrests)
plot(mod1, which = 4)

# Modelos lineales: Pregunta 3
mod1 = lm(Murder ~ Rape + Assault, data = USArrests)
newData = expand.grid(Rape = seq(from = 7, to = 16, by = 1), 
                      Assault = seq(from = 45, to = 337, by = 2))
predict(object = mod1, newdata = newData, interval = 'prediction')
