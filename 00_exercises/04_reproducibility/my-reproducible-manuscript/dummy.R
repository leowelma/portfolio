# Load penguins
library(ggplot2)

# Read data
# change to your repository path
penguins <- read.csv("00_exercises/04_reproducibility/my-reproducible-manuscript/data.csv")

# Plot penguins
ggplot(penguins, 
       aes(x = `Flipper.Length..mm.`, y = `Culmen.Length..mm.`)) +
  geom_point(aes(color = Species, shape = Species)) +
  scale_color_manual(values = c("darkorange","purple","cyan4")) +
  labs(
    title = "Flipper and Culmen length",
    subtitle = "Dimensions for penguins at Palmer Station LTER",
    x = "Flipper length (mm)", y = "Culmen length (mm)",
    color = "Penguin species", shape = "Penguin species"
  ) +
  theme_minimal()