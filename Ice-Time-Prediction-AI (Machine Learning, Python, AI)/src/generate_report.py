import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


# ---------------------------
# 1. Load Data for Preprocessing and Clean Data
# ---------------------------
def load_and_clean_data(filepath):
    """
    Load the dataset from Excel, remove unnecessary columns, and filter out goalies.

    """
    # Load data from Excel
    data = pd.read_excel(filepath)

    # Remove rows where 'Pos' is 'G' (Goalies)
    data = data[data['Pos'] != 'G']

    # List of columns to remove
    columns_to_remove = [
        'Rk', 'Team',  # Unnecessary values
        'TOI', 'ES', 'PP', 'SH',  # Time on Ice stats
        'PPP%',  # Power play points percentage (redundant with PPP)
        'G/GP', 'A/GP', 'P/GP',  # Per-game stats
        'G/60', 'A/60', 'P/60', 'ESG/60', 'ESA/60', 'ESP/60', 'PPG/60', 'PPA/60', 'PPP/60'  # Per-60 stats
    ]

    # Drop unnecessary columns
    data = data.drop(columns=columns_to_remove, errors='ignore')

    # Drop rows with missing values
    data = data.dropna()

    return data



# ---------------------------
# 2. Generate Descriptive Statistics
# ---------------------------

def descriptive_statistics(data, report_folder):
    """
    Generate descriptive statistics and save to a CSV file.

    """
    desc_stats = data.describe()  # Data BEFORE scaling
    desc_stats.to_csv(f"{report_folder}/descriptive_statistics.csv")
    print("Descriptive statistics saved.")


# ---------------------------
# 3. Distribution Plots for Key Features
# ---------------------------

def distribution_plots(data, report_folder):
    """
    Generate distribution plots for key numerical features before scaling.
    """
    numerical_columns = ['GP', 'G', 'A', 'P', 'PIM', 'HITS', 'BS', 'PPP', 'SHP', 'FOW', 'FOL', 'FO%', 'SH%']

    # Ensure SH% is properly converted to numerical format
    data['SH%'] = data['SH%'].str.rstrip('%').astype(float)  # Convert SH% to float

    for col in numerical_columns:
        plt.figure(figsize=(8, 6))

        # For Shooting Percentage, apply custom settings to reduce clutter
        if col == 'SH%':
            # Remove extreme outliers for SH% (focus on realistic values like 0% to 50%)
            filtered_data = data[data['SH%'] <= 50]
            sns.histplot(filtered_data['SH%'], bins=30, kde=True)
            plt.xlim(0, 50)  # Focus on the 0% to 50% range
        else:
            sns.histplot(data[col], bins=20, kde=True)

        plt.title(f'Distribution of {col}')
        plt.savefig(f"{report_folder}/{col}_distribution.png")
        plt.close()

    print("Distribution plots saved.")


# ---------------------------
# 4. Correlation Heatmap
# ---------------------------

def correlation_heatmap(data, report_folder, threshold=0.3):
    """
    Generate a heatmap for feature correlations, excluding non-numeric columns.
    Only shows correlations above a certain threshold for better readability.

    """
    # Filter out non-numeric columns
    numeric_data = data.select_dtypes(include=[float, int])

    # Generate the correlation matrix for numeric columns only
    corr_matrix = numeric_data.corr()

    # Apply the threshold (only show correlations above or below the threshold)
    mask = abs(corr_matrix) >= threshold

    # Plot the heatmap with the threshold mask
    plt.figure(figsize=(20, 15))
    sns.heatmap(corr_matrix[mask], annot=True, cmap='coolwarm', fmt=".2f", cbar=True)
    plt.title(f"Correlation Heatmap (Threshold = {threshold})")
    plt.savefig(f"{report_folder}/correlation_heatmap.png")
    plt.close()
    print("Correlation heatmap saved.")


# ---------------------------
# 5. Main Pre-Model Training Report Function
# ---------------------------

def generate_report(filepath, report_folder):
    """
    Generate a pre-model training report with descriptive statistics, distribution plots, and correlations.

    """
    # Load and clean the data
    data = load_and_clean_data(filepath)

    # Generate descriptive statistics
    descriptive_statistics(data, report_folder)

    # Generate distribution plots for numerical features
    distribution_plots(data, report_folder)

    # Generate correlation heatmap
    correlation_heatmap(data, report_folder)


    print(f"Pre-model training report has been generated and saved to {report_folder}.")


# ---------------------------
# Example usage
# ---------------------------

if __name__ == "__main__":
    input_filepath = "C:/Classe/fall 2024/ai/projet 1/data/All_Skaters.xlsx"
    report_folder = "C:/Classe/fall 2024/ai/projet 1/reports"
    generate_report(input_filepath, report_folder)
