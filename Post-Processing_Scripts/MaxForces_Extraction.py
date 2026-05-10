import pandas as pd
import os

# Root directory (update if needed)
root_dir = os.path.join("..", "15Aug")

# Output file
output_file = "MaxForces.csv"

# List to store results
results = []

# Loop over defence types
for defence in ["Dike", "Hybrid","New","Wall"]:
    defence_path = os.path.join(root_dir, defence)

    # Loop over cases (G1, G2, T4, T7)
    for case in ["G1", "G2", "T4", "T7"]:
        case_path = os.path.join(defence_path, case, f"{defence}_out", "forces", "_DikeForce.csv")

        if os.path.exists(case_path):
            try:
                # Read CSV
                df = pd.read_csv(case_path, delimiter=";")
                df.columns = df.columns.str.strip()  # Clean column names

                # Ensure correct column exists
                if "ForceFluid.x [N/m]" in df.columns:
                    df["ForceFluid.x [N/m]"] = pd.to_numeric(df["ForceFluid.x [N/m]"], errors="coerce")
                    max_force = df["ForceFluid.x [N/m]"].max()
                else:
                    max_force = None

                # Store result
                results.append({
                    "DefenceType": defence,
                    "Case": case,
                    "MaxForce": max_force
                })

            except Exception as e:
                print(f"Error reading {case_path}: {e}")
        else:
            print(f"File not found: {case_path}")

# Save all results into one CSV
results_df = pd.DataFrame(results)
results_df.to_csv(output_file, index=False)

print(f"✅ Results saved to {output_file}")
