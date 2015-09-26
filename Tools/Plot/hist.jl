#!/usr/bin/env julia

using Gadfly

function hist(x::Array{Float64}; file="plot.png")
   myplot = plot(x=x, Geom.histogram) 
   draw(PNG(file), myplot)
end

hist([1.0, 2.0, 3.0, 4.0, 5.0, 5.0])
