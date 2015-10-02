#!/usr/bin/env julia
# Code from My-Data-Science-Tool-Box at https://github.com/dmoliveira/My-Data-Science-Toolbox

# Title: Plot.jl
# Description: Fast plots in Julia + Gadfly at command-line. Supported plots: Hist, Scatter and Smooth Curve.
# Tags: Julia, Gadfly, Plots.


using Gadfly
using DataFrames

abstract Plot
abstract Hist <: Plot
abstract Scatter <: Plot
abstract Line <: Plot
abstract Smooth <: Plot
abstract Regression <: Plot
abstract Boxplot <: Plot
abstract Rectbin <: Plot
abstract Hexbin <: Plot

abstract InputFormat
abstract NumberList <: InputFormat
abstract File <: InputFormat

abstract OutputFormat 
abstract PNG <: OutputFormat

function plot(::Type{Hist}, data::Array)
    length(data) == 0 && error("No data to plot.")
    labels = map(n -> fill(repr(n), length(data[1])), 1:size(data)[1])
    dataframe = DataFrame(x=vcat(data...), label=vcat(labels...))
    Gadfly.plot(dataframe, x="x", color="label", Geom.histogram)
end

function plot(::Type{Scatter}, data::Array)
    length(data) == 0 && error("No data to plot.")
    length(data) % 2 != 0 && error("Scatter data need to be plotted at pairs [(X1, Y1), (X2, Y2)].")
    x = map(n -> data[n], 1:2:size(data)[1])
    y = map(n -> data[n], 2:2:size(data)[1])
    labels = map(n -> fill(repr(Int64(floor(n/2+1))), length(data[1])), 1:2:size(data)[1])
    dataframe = DataFrame(x=vcat(x...), y=vcat(y...), label=vcat(labels...))
    Gadfly.plot(dataframe, x="x", y="y", color="label")
end

plot(::Type{Line}, data::Array) = plot(Regression, data, Geom.line)
plot(::Type{Smooth}, data::Array) = plot(Regression, data, Geom.smooth)
function plot(::Type{Regression}, data::Array, geom)
    length(data) == 0 && error("No data to plot.")
    x = map(n -> [1:length(data[n])], 1:size(data)[1])
    y = map(n -> data[n], 1:size(data)[1])
    labels = map(n -> fill(repr(n), length(data[1])), 1:size(data)[1])
    dataframe = DataFrame(x=vcat(x...), y=vcat(y...), label=vcat(labels...))
    Gadfly.plot(dataframe, x="x", y="y", color="label", Geom.point, geom)
end

function plot(::Type{Boxplot}, data::Array)
    length(data) == 0 && error("No data to plot.")
    labels = map(n -> fill(repr(n), length(data[1])), 1:size(data)[1])
    dataframe = DataFrame(label=vcat(labels...), y=vcat(data...))
    Gadfly.plot(dataframe, x="label", y="y", Geom.boxplot)
end

function plot(::Type{Rectbin}, data::Array)
    length(data) != 3 && error("It needs three series (X, Y and Z).")
    dataframe = DataFrame(x=data[1], y=data[2], z=data[3])
    Gadfly.plot(dataframe, x="x", y="y", color="z", Geom.rectbin)
end

function plot(::Type{Hexbin}, data::Array)
    length(data) != 2 && error("It needs two series (X and Y).")
    dataframe = DataFrame(x=data[1], y=data[2])
    Gadfly.plot(dataframe, x="x", y="y", Geom.hexbin(xbincount=100, ybincount=100))
end

save(::Type{PNG}, output, plot; width=8inch, height=6inch) = draw(Compose.PNG(output, width, height), plot)

function parse_args(args)
    length(args) < 2 && error("Arguments wrong. It needs plot_type, x, [y] and [outputfile].")

    check_plot_type(args[1])
    plot_type = eval(parse(args[1]))

    output, data_args = parse_output_data_args(args)

    data = [parse_input(data) for data in data_args]
    plot_type, output, data
end

function check_plot_type(plot_type)
    valid_types = map(repr, [Hist, Scatter, Line, Smooth, Boxplot, Rectbin, Hexbin])
    in(plot_type, valid_types) || error("Plot type '$plot_type' "*
       "not supported. Accept only: $valid_types")
end

check_output_format(output) = ismatch(Regex("[.]$(lowercase(repr(PNG)))\$"), lowercase(output))
function parse_output_data_args(args)
    if check_output_format(args[2])
        output = args[2]
        length(args) > 2 || 
        error("""Need to inform list numbers. 
                 Only detected plot type ($plot_type) 
                 and output ($output).""")
        data_args = args[3:end]
    else
        timestamp = replace(repr(now()), ":", ".")
        output = "plot_$timestamp.png"
        data_args = args[2:end]
    end
    output, data_args
end

parse_input(data::AbstractString) = isfile(data)? parse_input(File, data) : parse_input(NumberList, data) 
parse_input(::Type{NumberList}, data::AbstractString) = map(n -> parse(Float64, n), split(data))
function parse_input(::Type{File}, file::AbstractString)
    open(file) do f
        lines = readlines(f)
        length(lines) == 0 && error("File '$file' is empty.")
        lines = length(lines) > 1? replace(strip(join(lines)), '\n', ' ') : lines[1]
        parse_input(NumberList, lines)
    end
end

function gen_dataframe(data)

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
    ```
    plot.jl Hist "1 2 3" my_plot.png
    ```
    ```
    plot.jl Scatter ".5 .2 .15 .40" ".1 .26 .65 .78"
    ```
"""
function main(args)
    plot_type, output, data = parse_args(args)
    p = plot(plot_type, data)
    save(PNG, output, p)
end

main(ARGS)
