# Respuestas Quiz 1 -------------------------------------------------------

# Tendencia central: Pregunta 1

head(iris, n= 5)

# Tendencia central: Pregunta 2

mean(iris$Sepal.Width)

# Tendencia central: Pregunta 3

DescTools::Mode(iris$Species)

# Tendencia central: Pregunta 4

median(iris$Sepal.Length)

# Tendencia central: Pregunta 5

sum(airquality$Wind)/length(airquality$Wind)

# Tendencia central: Pregunta 6

USArrests[which.max(USArrests$Murder), ]

# Tendencia central: Pregunta 7

# Moda / Mediana

# Dispersion: Pregunta 1

var(iris$Sepal.Length)

# Dispersion: Pregunta 2

sd(iris$Petal.Length)/mean(iris$Petal.Length)

# Dispersion: Pregunta 3

IQR(iris$Sepal.Width)

# Dispersion: Pregunta 4

quantile(x = iris$Sepal.Width, probs = 0.14)

# Figuras: Pregunta 1

boxplot(iris$Sepal.Length)

# Figuras: Pregunta 2

plot(density(iris$Petal.Length))

# Probabilidad: Pregunta 1

1 - pnorm(q = 5.5, mean = mean(iris$Sepal.Length), sd = sd(iris$Sepal.Length))

# Probabilidad: Pregunta 2

dnorm(x = 70, mean = mean(airquality$Temp), sd = sd(airquality$Temp))

