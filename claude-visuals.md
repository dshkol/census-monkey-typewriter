
This document will detail visual and aesthetic expectations for Claude to rely on when constructing visual material and will be updated over time 


### Plot types
- Always make maps when appropriate
- Make use of a varied range of visualization styles as appropriate
- Use lollipop plots from the ggalt package when bar charts are too condensed with too many items
- Use ridgeline plots from the ggridgeline package to display comparative densities 


### Colour schemes 
- Use viridis palettes for choropleth maps or any other visualization that requires a color ramp. 
- Use simple consistent palettes where appropriate for other graphics, especially bar and column charts. No need to use color palettes in bar/col charts that are explicitly labelled on the axes. Use a very dark grey and white color scheme.

### GGPlot theming
- use `theme_minimal` in most situations. Use  `theme_void` for maps. 
- Axes should be labelled if important; if unimportant, they should not have their text show up
- Use `labs(subtitle = ...)` to title the plots 
- Use `labs(caption = ...)` to write captions with attribution, where appropriate. Use right justification for captions

