import pandas as pd
from sklearn.preprocessing import StandardScaler, LabelEncoder

# ---------------------------
# 1. Load Data (from Excel file)
# ---------------------------

def load_data(filepath):
    """
    Load dataset from an Excel file.

    Returns:
    pandas.DataFrame: Loaded dataset.
    """
    return pd.read_excel(filepath)

# ---------------------------
# 2. Remove Goalies
# ---------------------------

def remove_goalies(data):
    """
    Remove goalies from the dataset (assuming 'Pos' column contains 'G' for goalies).

    Returns:
    pandas.DataFrame: Dataset without goalies.
    """
    return data[data['Pos'] != 'G']

# ---------------------------
# 3. Clean Data (Remove unnecessary columns)
# ---------------------------

def clean_data(data):
    """
    Clean the dataset by removing unnecessary columns and handling missing values.

    Returns:
    pandas.DataFrame: Cleaned dataset.
    """
    # List of columns to remove
    columns_to_remove = [
        'Name', 'Team', 'Rk',  # Unnecessary columns
        'ES', 'PP', 'SH',  # Specific time stats
        'PPP%',  # Power play points percentage (redundant with PPP)
        'G/GP', 'A/GP', 'P/GP',  # Per-game stats that are too complex
        'G/60', 'A/60', 'P/60', 'ESG/60', 'ESA/60', 'ESP/60', 'PPG/60', 'PPA/60', 'PPP/60'
    ]

    # Drop unnecessary columns
    data = data.drop(columns=columns_to_remove, errors='ignore')

    # Drop rows with missing values
    data = data.dropna()

    return data

# ---------------------------
# 4. Preprocess Data (Encoding and Scaling)
# ---------------------------

def preprocess_data(data):
    """
    Preprocess the dataset by scaling numerical features and encoding categorical variables.

    Returns:
    pandas.DataFrame: Preprocessed dataset.
    """
    # Convert percentage columns to numeric
    data['FO%'] = data['FO%'].str.rstrip('%').astype('float') / 100
    data['SH%'] = data['SH%'].str.rstrip('%').astype('float') / 100

    # Scale numerical features
    scaler = StandardScaler()
    numerical_columns = [
        'GP', 'G', 'A', 'P', 'PIM', '+/-', 'HITS', 'BS', 'PPP', 'SHP', 'FOW', 'FOL', 'FO%', 'SH%'
    ]
    data[numerical_columns] = scaler.fit_transform(data[numerical_columns])

    # Encode categorical variables
    label_encoder = LabelEncoder()
    categorical_columns = ['Pos']
    for column in categorical_columns:
        data[column] = label_encoder.fit_transform(data[column])

    return data

# ---------------------------
# 5. Feature Engineering
# ---------------------------

def create_features(data):
    """
    Create new features from existing data.

    Returns:
    pandas.DataFrame: Dataset with new features.
    """
    # Create a new feature for goal-to-assist ratio
    data['goal_assist_ratio'] = data['G'] / (data['A'] + 1)  # Adding 1 to avoid division by zero

    return data

# ---------------------------
# 6. Main Preprocessing Function
# ---------------------------

def preprocess_pipeline(filepath, output_filepath):
    """
    Full preprocessing pipeline: load, clean, preprocess, and add new features.
    """
    data = load_data(filepath)
    data = remove_goalies(data)
    data = clean_data(data)
    data = preprocess_data(data)
    data = create_features(data)

    # Save the cleaned data to CSV
    data.to_csv(output_filepath, index=False)
    print(f"Cleaned data saved to {output_filepath}")

# Example usage:
if __name__ == "__main__":
    input_filepath = "C:/Classe/Winter 2024/ai/projet 1/data/All_Skaters.xlsx"
    output_filepath = "C:/Classe/Winter 2024/ai/projet 1/data/Cleaned_Skaters.csv"
    preprocess_pipeline(input_filepath, output_filepath)
