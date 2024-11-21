import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.metrics import mean_squared_error, r2_score
import joblib
import ast

# ---------------------------
# 1. Load Preprocessed Data
# ---------------------------

def load_data(filepath):
    """
    Load the preprocessed dataset from CSV file.
    """
    return pd.read_csv(filepath)

# Load the data
data = load_data('C:/Classe/fall 2024/ai/projet 1/data/Cleaned_Skaters.csv')

# Convert 'TOI' from 'MM:SS' to total minutes
data['TOI'] = data['TOI'].apply(
    lambda x: sum(int(i) * 60 ** index for index, i in enumerate(reversed(x.split(':')))) / 60)

# Create 'goal_assist_ratio' and 'points' features
data['goal_assist_ratio'] = data['G'] / (data['A'] + 1e-9)  # Avoid division by zero
data['points'] = data['G'] + data['A']

# Select final features
final_features = ['A', 'BS', 'Pos', 'PPP', 'SHOTS', 'GP', 'Age', 'G', 'goal_assist_ratio', 'points']
X = data[final_features]  # Use only the selected features
y = data['TOI']  # Target column

# Train/test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# ---------------------------
# 2. Train Gradient Boosting Model with Best Hyperparameters
# ---------------------------

# Load best hyperparameters from the file
with open('best_hyperparameters.txt', 'r') as f:
    best_params = ast.literal_eval(f.read())  # Convert string back to dictionary

# Train the model with the best hyperparameters
model = GradientBoostingRegressor(**best_params)
model.fit(X_train, y_train)

# Evaluate the final model
y_pred = model.predict(X_test)
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)
rmse = mse ** 0.5

print(f"Mean Squared Error: {mse}")
print(f"R² Score: {r2}")
print(f"Root Mean Squared Error: {rmse}")

# Save the final model
joblib.dump(model, 'final_gradient_boosting_model.pkl')
print("Final model saved as 'final_gradient_boosting_model.pkl'")
