import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import GradientBoostingRegressor

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
# 2. Fine-Tuning with GridSearchCV
# ---------------------------

# Define hyperparameter grid for fine-tuning
param_grid = {
    'learning_rate': [0.01, 0.05, 0.1],
    'n_estimators': [100, 200, 300],
    'max_depth': [3, 4, 5],
    'subsample': [0.7, 0.8, 1.0]
}

# Perform GridSearchCV to find the best parameters
grid_search = GridSearchCV(estimator=GradientBoostingRegressor(), param_grid=param_grid, cv=5, n_jobs=-1, scoring='r2')
grid_search.fit(X_train, y_train)

# Print best hyperparameters
print("Best hyperparameters found by GridSearchCV:")
print(grid_search.best_params_)

# Save the hyperparameters to a file
with open('best_hyperparameters.txt', 'w') as f:
    f.write(str(grid_search.best_params_))
