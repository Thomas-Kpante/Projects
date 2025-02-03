# Data Mining Project: K-Means Clustering on Consumer Personality Data

This repository contains a project exploring consumer data using K-Means clustering, MongoDB, and Python. The objective is to identify different consumer patterns based on spending habits.

---

## 📂 Project Structure

- **notebook/**: Jupyter notebook containing data cleaning, analysis, and clustering. (NOTEBOOK IS IN FRENCH)
  
- **mongo_queries/**: MongoDB aggregation queries for specific analyses.
  - `CommandeMongoDBAggregate.json`: JSON file with aggregation queries for income and family-related insights.

- **data/**: Folder containing any datasets used (if applicable).
  - `dataset.csv`: Consumer data used in this project.

  
---

## 🔧 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/repo-name.git
   cd repo-name
   ```

2. Install the necessary Python packages:
   ```bash
   pip install -r requirements.txt
   ```

🚀 **Running the Notebooks**

3. Ensure MongoDB is running and contains the necessary data:
   ```bash
   mongod
   ```

4. Open the notebooks using Jupyter:
   ```bash
   jupyter notebook
   ```

5. Execute the cells in the following order:
   - `ProjetK.ipynb` 

📊 **Results Overview**

- **Data Cleaning**: Missing values were handled using the median, and invalid data (like incorrect ages) was removed.
- **Correlation Analysis**: A heatmap was generated to visualize the relationship between key variables.
- **K-Means Clustering**: Consumers were segmented into clusters based on spending and income, as shown in the scatter plot.

**Key Visualizations:**
- **Age Distribution**
- **Spending vs. Marital Status**

📂 **MongoDB Aggregation Queries**

Three key aggregation queries were executed using MongoDB:

1. **Maximum income among consumers**:
   - File: `CommandeMongoDBAggregate.json`
   - Command: See query for `$max`.
   
2. **Number of consumers without children**:
   - Aggregation with `$match` and `$count`.
   
3. **Average income for parents with two children**:
   - Matching and grouping via `$avg`.


