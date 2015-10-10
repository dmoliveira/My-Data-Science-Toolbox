#!/usr/bin/env bash

# Throw error if occurs exceptions
set -e

# # Test 01::Histogram
# ../fastviz.jl Hist "./test_plot_hist01.png" "1 4 5 3 3 5 1 2 5"
# 
# # Test 02::Scatter
# ../fastviz.jl Scatter "./test_plot_scatter02.png" "1 4 4 3 3 3 1 2 5 10" "5 5 5 1 2 2 6 7 7 7"
# 
# # Test 03::Smooth
# ../fastviz.jl Smooth "./test_plot_smooth03.png" "1 4 4 3 3 3 1 2 5 10" "5 5 5 1 2 2 6 7 7 7"
# 
# # Test 04::Scatter with file as input source
# ../fastviz.jl Scatter "./test_plot_scatter04.png" "../sample/iris-data-x.txt" "../sample/iris-data-y.txt"
# 
# # Test 05::Boxplot
# ../fastviz.jl Boxplot "./test_plot_boxplot05.png" "../sample/iris-data-x.txt" "../sample/iris-data-y.txt"

# Test 06::Recbin
../fastviz.jl Rectbin "./test_plot_rectbin06.png" "1 2 3 4 5" "11 12 13 14 15" "21 22 23 24 25"

# Test 07::Hexbin
../fastviz.jl Hexbin "./test_plot_hexbin07.png" "$(seq 1 .1 4 | tr '\n' ' ')" "$(seq 1 .1 4 | tr '\n' ' ')"

# Test 08::Smooth real use exchance currency (USR and BRL x EUR)
USDxEUR="1.0967 1.0967 1.0951 1.0973 1.0883 1.0885 1.0941 1.0941 1.0941 1.096 1.1055 1.1155 1.1109 1.1171 1.1171 1.1171 1.11 1.106 1.1041 1.1183 1.1281 1.1281 1.1281 1.1497 1.1506 1.1402 1.1284 1.1268 1.1268 1.1268 1.1215"
BRLxEUR="3.6974 3.6974 3.7824 3.7718 3.7721 3.8273 3.8579 3.8579 3.8579 3.8559 3.8366 3.8597 3.8793 3.91 3.91 3.91 3.8851 3.8564 3.8404 3.919 3.9161 3.9161 3.9161 4.0935 4.0621 4.0954 4.0435 4.0171 4.0171 4.0171 4.0671"
../fastviz.jl Smooth "./test_plot_smooth_08.png" "$USDxEUR" "$BRLxEUR"

exit 0
