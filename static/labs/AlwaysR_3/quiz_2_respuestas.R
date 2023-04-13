
# Respuestas Quiz 2 -------------------------------------------------------

# Repaso: Pregunta 1
tapply(X = mtcars$mpg, INDEX = mtcars$am, FUN = var)

# Repaso: Pregunta 2
table(mtcars$am, mtcars$vs)

# Repaso: Pregunta 3
summary(mtcars)

# Repaso: Pregunta 4
library(ggplot2)
ggplot(data = mtcars, aes(x = mpg, y = drat, color = factor(am))) +
  geom_point()

# Prueba de hipotesis: Pregunta 1
t.test(x = medA, y = medB, alternative = 'two.sided', paired = FALSE, mu = 0, var.equal = FALSE)

# Prueba de hipotesis: Pregunta 2
t.test(x = concO2, alternative = 'greater', mu = 60)

# Prueba de hipotesis: Pregunta 3
chisq.test(myTab)

# Prueba de hipotesis: Pregunta 4
head(Anorexia)
t.test(x = Anorexia$Prior, y = Anorexia$Post, alternative = 'greater', mu = 0, paired = TRUE)

# ANOVA: Pregunta 1
myAnov = aov(mpg ~ am, data = mtcars)
summary(myAnov)

# ANOVA: Pregunta 2
myAnova = aov(mpg ~ am, data = mtcars)
plot(myAnova, 2)
