import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression, Ridge
from sklearn.ensemble import RandomForestRegressor, AdaBoostRegressor, GradientBoostingRegressor
from sklearn.svm import SVR
from xgboost import XGBRegressor
from sklearn.metrics import mean_squared_error, r2_score, root_mean_squared_error

# ---------------------------
# 1. Load Preprocessed Data
# ---------------------------

def load_data(filepath):
    """
    Load the preprocessed dataset from CSV file.
    """
    return pd.read_csv(filepath)

# ---------------------------
# 2. Train and Evaluate Model
# ---------------------------

def train_and_evaluate_model(model, X_train, X_test, y_train, y_test, model_name):
    """
    Train the model and evaluate its performance on the test set.
    """
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)

    # Evaluate the model
    mse = mean_squared_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)
    # Updated RMSE calculation to avoid the FutureWarning
    rmse = root_mean_squared_error(y_test, y_pred)

    print(f"Model: {model_name}")
    print(f"Mean Squared Error: {mse}")
    print(f"R² Score: {r2}")
    print(f"Root Mean Squared Error: {rmse}")
    print("-" * 40)

# ---------------------------
# 3. Main Training Function
# ---------------------------

def main():
    # Load the preprocessed and scaled data
    data = load_data('C:/Classe/fall 2024/ai/projet 1/data/Cleaned_Skaters.csv')

    # Convert 'TOI' from 'MM:SS' to total minutes
    data['TOI'] = data['TOI'].apply(
        lambda x: sum(int(i) * 60 ** index for index, i in enumerate(reversed(str(x).split(':')))) / 60)

    # Split into features (X) and target (y)
    X = data.drop(columns=['TOI'])  # Ensure this is the correct column for time on ice
    y = data['TOI']

    # Train/test split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Models to train with their best hyperparameters
    models = [
        (LinearRegression(), "Linear Regression"),
        (Ridge(alpha=10), "Ridge Regression"),
        (RandomForestRegressor(
            n_estimators=200,
            max_depth=10,
            min_samples_split=2,
            min_samples_leaf=2,
            bootstrap=True,
            random_state=42
        ), "Random Forest"),
        (SVR(C=1, gamma='scale', kernel='linear'), "Support Vector Regression (SVR)"),
        (AdaBoostRegressor(
            n_estimators=50,
            learning_rate=0.1,
            random_state=42
        ), "AdaBoost"),
        (GradientBoostingRegressor(
            n_estimators=200,
            learning_rate=0.1,
            max_depth=3,
            subsample=0.8,
            random_state=42
        ), "Gradient Boosting"),
        (XGBRegressor(
            n_estimators=200,
            learning_rate=0.1,
            max_depth=3,
            subsample=0.8,
            colsample_bytree=0.8,
            random_state=42
        ), "XGBoost")
    ]

    # Train and evaluate all models
    for model, model_name in models:
        train_and_evaluate_model(model, X_train, X_test, y_train, y_test, model_name)

if __name__ == "__main__":
    main()
