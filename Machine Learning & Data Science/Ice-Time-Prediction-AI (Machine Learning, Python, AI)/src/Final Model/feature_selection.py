import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
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

# Split into features (X) and target (y)
X = data.drop(columns=['TOI'])  # Drop the target column
y = data['TOI']  # Target column

# Train/test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# ---------------------------
# 2. Train Gradient Boosting and Analyze Feature Importance
# ---------------------------
# Train the Gradient Boosting model
model = GradientBoostingRegressor(learning_rate=0.1, max_depth=3, n_estimators=200, subsample=0.8)
model.fit(X_train, y_train)

# Get feature importance
importances = model.feature_importances_

# Sort the feature importances and corresponding features
indices = np.argsort(importances)[::-1]

# Get the top 10 features
top_10_indices = indices[:10]
top_10_features = X_train.columns[top_10_indices]

# Print the feature ranking
print("Top 10 Feature ranking before removing correlated ones:")
for i in range(10):
    print(f"{i + 1}. Feature {top_10_features[i]} ({importances[top_10_indices[i]]})")

# ---------------------------
# 3. Identify and Remove Correlated Features from the Top 10
# ---------------------------
# Assuming your dataset is loaded as 'data'
corr_matrix = data[top_10_features].corr()

# Set a threshold for correlation (e.g., above 0.92)
threshold = 0.92

# Find pairs of highly correlated features
high_corr_pairs = [(i, j) for i in corr_matrix.columns for j in corr_matrix.columns
                   if i != j and abs(corr_matrix.loc[i, j]) > threshold]

print("\nHighly correlated features in the top 10 (above threshold):")
for pair in high_corr_pairs:
    print(f"{pair[0]} and {pair[1]} with correlation: {corr_matrix.loc[pair[0], pair[1]]}")

# Remove correlated features: remove 'ESA' and 'PPA' based on prior analysis
features_to_remove = ['ESA', 'PPA']

# Keep the remaining features
final_features = [f for f in top_10_features if f not in features_to_remove]

print("\nFinal features used for modeling after removing correlated ones:")
print(final_features)

# ---------------------------
# 4. Train and Evaluate the Model with Reduced Features
# ---------------------------
X_train_reduced = X_train[final_features]
X_test_reduced = X_test[final_features]

# Train the Gradient Boosting model again with reduced features
model_reduced = GradientBoostingRegressor(learning_rate=0.1, max_depth=3, n_estimators=200, subsample=0.8)
model_reduced.fit(X_train_reduced, y_train)

# Predict and evaluate the model
y_pred = model_reduced.predict(X_test_reduced)
mse = np.mean((y_test - y_pred) ** 2)
rmse = np.sqrt(mse)
r2 = model_reduced.score(X_test_reduced, y_test)

print(f"\nModel evaluation with reduced features:")
print(f"Mean Squared Error: {mse}")
print(f"Root Mean Squared Error: {rmse}")
print(f"R² Score: {r2}")

# ---------------------------
# 5. Summary of Model Changes
# ---------------------------
print("\nSummary of Model Changes:")
print("1. Used Gradient Boosting to identify top 10 most important features.")
print("2. Removed correlated features (ESA and PPA).")
print("3. Trained a new model using only the remaining features for a smaller, more efficient model.")
