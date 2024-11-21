import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.linear_model import LinearRegression, Ridge
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor, AdaBoostRegressor
from sklearn.svm import SVR
from xgboost import XGBRegressor
from sklearn.metrics import mean_squared_error

# ---------------------------
# 1. Load Preprocessed Data
# ---------------------------
def load_data(filepath):
    """Load the preprocessed dataset from CSV file."""
    return pd.read_csv(filepath)

# ---------------------------
# 2. Hyperparameter Tuning for Various Models
# ---------------------------

def tune_random_forest(X_train, y_train):
    """Tune Random Forest hyperparameters using GridSearchCV."""
    param_grid_rf = {
        'n_estimators': [100, 200],
        'max_depth': [10, 20, None],
        'min_samples_split': [2, 5, 10],
        'min_samples_leaf': [1, 2, 4],
        'bootstrap': [True, False]
    }
    grid_search_rf = GridSearchCV(RandomForestRegressor(random_state=42), param_grid_rf,
                                  cv=5, scoring='neg_mean_squared_error', verbose=2, n_jobs=-1)
    grid_search_rf.fit(X_train, y_train)
    print(f"Best parameters for Random Forest: {grid_search_rf.best_params_}")
    return grid_search_rf.best_estimator_

def tune_svr(X_train, y_train):
    """Tune SVR hyperparameters using GridSearchCV."""
    param_grid_svr = {
        'C': [0.1, 1, 10],
        'gamma': ['scale', 'auto', 0.1, 1, 10],
        'kernel': ['rbf', 'linear']
    }
    grid_search_svr = GridSearchCV(SVR(), param_grid_svr, cv=5, scoring='r2', verbose=2, n_jobs=-1)
    grid_search_svr.fit(X_train, y_train)
    print(f"Best parameters for SVR: {grid_search_svr.best_params_}")
    return grid_search_svr.best_estimator_

def tune_xgboost(X_train, y_train):
    """Tune XGBoost hyperparameters using GridSearchCV."""
    param_grid_xgb = {
        'n_estimators': [100, 200],
        'learning_rate': [0.01, 0.1],
        'max_depth': [3, 5, 10],
        'subsample': [0.8, 1],
        'colsample_bytree': [0.8, 1]
    }
    grid_search_xgb = GridSearchCV(XGBRegressor(random_state=42), param_grid_xgb,
                                   cv=5, scoring='neg_mean_squared_error', verbose=2, n_jobs=-1)
    grid_search_xgb.fit(X_train, y_train)
    print(f"Best parameters for XGBoost: {grid_search_xgb.best_params_}")
    return grid_search_xgb.best_estimator_

def tune_gradient_boosting(X_train, y_train):
    """Tune Gradient Boosting hyperparameters using GridSearchCV."""
    param_grid_gb = {
        'n_estimators': [100, 200],
        'learning_rate': [0.01, 0.1, 0.2],
        'max_depth': [3, 5, 10],
        'subsample': [0.8, 1.0]
    }
    grid_search_gb = GridSearchCV(GradientBoostingRegressor(random_state=42), param_grid_gb,
                                  cv=5, scoring='neg_mean_squared_error', verbose=2, n_jobs=-1)
    grid_search_gb.fit(X_train, y_train)
    print(f"Best parameters for Gradient Boosting: {grid_search_gb.best_params_}")
    return grid_search_gb.best_estimator_

def tune_adaboost(X_train, y_train):
    """Tune AdaBoost hyperparameters using GridSearchCV."""
    param_grid_ada = {
        'n_estimators': [50, 100, 200],
        'learning_rate': [0.01, 0.1, 1]
    }
    grid_search_ada = GridSearchCV(AdaBoostRegressor(random_state=42), param_grid_ada,
                                   cv=5, scoring='neg_mean_squared_error', verbose=2, n_jobs=-1)
    grid_search_ada.fit(X_train, y_train)
    print(f"Best parameters for AdaBoost: {grid_search_ada.best_params_}")
    return grid_search_ada.best_estimator_

def tune_ridge(X_train, y_train):
    """Tune Ridge Regression hyperparameters using GridSearchCV."""
    param_grid_ridge = {
        'alpha': [0.1, 1, 10, 100]
    }
    grid_search_ridge = GridSearchCV(Ridge(), param_grid_ridge, cv=5, scoring='neg_mean_squared_error', verbose=2, n_jobs=-1)
    grid_search_ridge.fit(X_train, y_train)
    print(f"Best parameters for Ridge Regression: {grid_search_ridge.best_params_}")
    return grid_search_ridge.best_estimator_

# ---------------------------
# 3. Main Function for Tuning
# ---------------------------
def main():
    # Load the preprocessed data
    data = load_data('C:/Classe/Winter 2024/ai/projet 1/data/Cleaned_Skaters.csv')

    # Convert 'TOI' from 'MM:SS' to total minutes
    data['TOI'] = data['TOI'].apply(
        lambda x: sum(int(i) * 60 ** index for index, i in enumerate(reversed(x.split(':')))) / 60)

    # Split into features (X) and target (y)
    X = data.drop(columns=['TOI'])  # Time on ice column
    y = data['TOI']

    # Train/test split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Perform hyperparameter tuning for each model
    print("Tuning Random Forest...")
    best_rf = tune_random_forest(X_train, y_train)

    print("Tuning Support Vector Regression (SVR)...")
    best_svr = tune_svr(X_train, y_train)

    print("Tuning XGBoost...")
    best_xgb = tune_xgboost(X_train, y_train)

    print("Tuning Gradient Boosting...")
    best_gb = tune_gradient_boosting(X_train, y_train)

    print("Tuning AdaBoost...")
    best_ada = tune_adaboost(X_train, y_train)

    print("Tuning Ridge Regression...")
    best_ridge = tune_ridge(X_train, y_train)

if __name__ == "__main__":
    main()

    #Best parameters for Ridge Regression: {'alpha': 10}
    #Best parameters for AdaBoost: {'learning_rate': 0.1, 'n_estimators': 50}
    #Best parameters for Gradient Boosting: {'learning_rate': 0.1, 'max_depth': 3, 'n_estimators': 200, 'subsample': 0.8}
    #Best parameters for XGBoost: {'colsample_bytree': 0.8, 'learning_rate': 0.1, 'max_depth': 3, 'n_estimators': 200, 'subsample': 0.8}
    #Best parameters for SVR: {'C': 1, 'gamma': 'scale', 'kernel': 'linear'}
    #Best parameters for Random Forest: {'bootstrap': True, 'max_depth': 10, 'min_samples_leaf': 2, 'min_samples_split': 2, 'n_estimators': 200}
