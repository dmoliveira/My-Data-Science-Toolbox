#!/usr/bin/env julia
using JLD
using DataFrames
using XGBoost

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
train = readtable("../data/train_featured.tsv", separator='\t')
test = readtable("../data/test_featured.tsv", separator='\t')

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

dtrain = DMatrix(train_x, label=train_y)
dval = DMatrix(val_x, label=val_y);

# XGBoost Parameters
num_rounds = 1000
params = Dict({"objective" => "multi:softmax",
               "booster" => "gbtree",
               "eta" => 0.3,
               "max_depth" => 5,
               "subsample" => 0.85
              })

println("""
    Start XGBoost Traininig
    ----------------------------
    Parameters
        Round Number: $num_rounds
        Params: $params
    """)

watchlist = [(dtrain, "train"), (dval, "eval")]

println("\nBase Model")
tic()
num_class = 39
model = XGBoost.xgboost(dtrain, num_rounds, param=params, 
                        num_class=num_class, watchlist=watchlist)
toc()

println("\nPrepare to Tunning Model")
tic()
ptrain = XGBoost.predict(model, dtrain, output_margin=true)
pval  = XGBoost.predict(model, dval, output_margin=true)

num_rounds = 1000
set_info(dtrain, "base_margin", ptrain)
set_info(dval, "base_margin", pval)
watchlist  = [(dtrain, "train2"), (dval, "eval2")]
toc()

println("\nTunning Model")
tic()
model = XGBoost.xgboost(dtrain, num_rounds, param=params, 
                        num_class=num_class, watchlist=watchlist)
toc()


println("\nStart Prediction")
tic()
pred_train = round(Int32, XGBoost.predict(model, train_x))
pred_val = round(Int32, XGBoost.predict(model, val_x))
pred_test = round(Int32, XGBoost.predict(model, test_x))
toc()

println("\nSave Predictions")
tic()
writetable("../data/pred_train_featured_department_relationship_xgb.csv", DataFrame(pred=pred_train))
writetable("../data/pred_val_featured_department_relationship_xgb.csv", DataFrame(pred=pred_val))
writetable("../data/pred_test_featured_department_relationship_xgb.csv", DataFrame(pred=pred_test))
toc()

println("\nFinished Execution")
