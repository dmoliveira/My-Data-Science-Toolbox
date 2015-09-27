#!/usr/bin/env julia
# Code from My-Data-Science-Tool-Box at https://github.com/dmoliveira/My-Data-Science-Toolbox

# Title: Plot.jl
# Description: Fast plots in Julia + Gadfly at command-line. Supported plots: Hist, Scatter and Smooth Curve.
# Tags: Julia, Gadfly, Plots.


using Gadfly

abstract Plot
abstract Hist <: Plot
abstract Scatter <: Plot
abstract Smooth <: Plot

render(::Type{Hist}, x::Array{Float64}) = plot(x=x, Geom.histogram)
render(::Type{Scatter}, x::Array{Float64}, y::Array{Float64}) = plot(x=x, y=y)
render(::Type{Smooth}, x::Array{Float64}, y::Array{Float64}) =  plot(x=x, y=y, Geom.point, Geom.smooth)

function parse_args(args)
    length(args) < 2 && error("Arguments wrong. It needs plot_type, x, [y] and [outputfile].")

    args[1] == "Hist" || args[1] == "Scatter" || args[1] == "Smooth" ||
    error("Plot type not supported.")

    plot_type = eval(parse(args[1]))
    x = map(x -> parse(Float64, x), split(args[2]))

    length(args) == 2 && return plot_type, x, "plot.png"

    ' ' in args[3] || return plot_type, x, args[3]

    y = map(y -> parse(Float64, y), split(args[3]))
    length(args) == 3 && return plot_type, x, y, "plot.png"

    outputfile = args[4]
    plot_type, x, y, outputfile
end

@doc """

    Description
    -----------
    Create plot in PNG format.
    Create only simple Histogram,
    Scatter plot or Smooth Curve.


    Arguments
    ---------
    - plot_type: Accept `Hist`, `Scatter` or `Smooth`.
    - x: Float elements separated by space only.
    - y (only for Scatter or Smooth): Float elements
        separated by space only.
    - output (optional): Output name to save PNG file.


    Examples
    --------
    ```plot.jl Hist "1 2 3" my_plot.png```
    ```plot.jl Scatter ".5 .2 .15 .40" ".1 .26 .65 .78"```
"""
function main(args)
    args = parse_args(args)
    p = render(args[1:end-1]...)
    draw(PNG(args[end], 8inch, 6inch), p)
end

main(ARGS)
