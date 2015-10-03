#!/usr/bin/env julia

using Test

@test fastviz.jl Hist ./tests/test_plot_hist01.png "$(seq 1 10)"
run("rm './tests/test_plot_hist01.png'")
