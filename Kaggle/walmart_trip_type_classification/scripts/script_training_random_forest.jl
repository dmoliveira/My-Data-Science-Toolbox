#!/usr/bin/env julia
using JLD
using DataFrames
using DecisionTree

# Auxliary Functions
function split_train_val(df; train_size=.85, random_state=1)
    srand(random_state)
    nrows = size(df, 1)
    indexes = shuffle(collect(1:nrows))
    train = df[indexes[1:round(Int, nrows*train_size)], :]
    validation = df[indexes[(round(Int, nrows*train_size)+1):end], :] 
    return train, validation
end

# Load Data
train = readtable("../data/train_featured_all_relationship.tsv", separator='\t')
test = readtable("../data/test_featured_all_relationship.tsv", separator='\t')

train = train[:, :]
test = test[:, :]

features = [:Weekday, :Upc, :ScanCount, :DepartmentDescription, :FinelineNumber]
label = :TripType

X_train, X_val = split_train_val(train, train_size=.85, random_state=1)
train_x = convert(Array{Float64,2}, X_train[:, features])
train_y = convert(Array{Float64,1}, X_train[label])
val_x = convert(Array{Float64,2}, X_val[:, features])
val_y = convert(Array{Float64,1}, X_val[label])
test_x = Array{Float64,2}(test[:, features])

# Random Forest Parameters
number_random_features = 50
tree_number = 1000
subsample = .5

println("""
    Start Random Forest Traininig
    ----------------------------
    Parameters
        Number Random Features: $number_random_features
        Tree number: $tree_number
        Sub-Sample: $subsample
    """)

tic()
model = build_forest(train_y, train_x, 5, 100, 0.5)
toc()


println("\nStart Prediction")
tic()
pred_train = round(Int32, apply_forest(model, train_x))
pred_val = round(Int32, apply_forest(model, val_x))
pred_test = round(Int32, apply_forest(model, test_x))
toc()

println("\nSave Predictions")
tic()
writetable("../data/pred_train_featured_all_relationship_rf.csv", DataFrame(pred=pred_train))
writetable("../data/pred_val_featured_all_relationship_rf.csv", DataFrame(pred=pred_val))
writetable("../data/pred_test_featured_all_relationship_rf.csv", DataFrame(pred=pred_test))
toc()

println("\nFinished Execution")