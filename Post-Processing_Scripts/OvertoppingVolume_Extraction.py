import pandas as pd
import os

# Root directory (update if needed)
root_dir = "15Aug"

# Output file
output_file = "Flowtool_InVolume_Summary.csv"

# Expected structure:
# 15Aug/
#  ├── Dike/G1/Dike_out/flowtool/_ResultBoxes.csv
#  ├── Dike/G2/Dike_out/flowtool/_ResultBoxes.csv
#  ├── ...
#  ├── Hybrid/G1/Hybrid_out/flowtool/_ResultBoxes.csv
#  └── Wall/T7/Wall_out/flowtool/_ResultBoxes.csv

def read_involume_sum(csv_path: str) -> float | None:
    """
    Reads _ResultBoxes.csv and returns the sum of 'InVolume_Past [m^3]'.
    Handles delimiter, header offset, and numeric coercion.
    """
    try:
        df = pd.read_csv(csv_path, delimiter=";", engine="python", skiprows=4)
        # Normalise headers (strip whitespace)
        df.columns = df.columns.str.strip()

        # Column name we expect
        col_name = "InVolume_Past [m^3]"
        if col_name not in df.columns:
            # Try a couple of common variants defensively
            candidates = [c for c in df.columns if c.replace(" ", "").lower() == "involume_past[m^3]".replace(" ", "").lower()]
            if candidates:
                col_name = candidates[0]
            else:
                print(f"⚠️ Column '{col_name}' not found in {csv_path}. Available columns: {list(df.columns)}")
                return None

        df[col_name] = pd.to_numeric(df[col_name], errors="coerce")
        return float(df[col_name].sum(skipna=True))
    except Exception as e:
        print(f"❌ Error reading {csv_path}: {e}")
        return None

results = []

for defence in ["Dike", "Hybrid", "New","Wall"]:
    defence_path = os.path.join(root_dir, defence)
    for case in ["G1", "G2", "T4", "T7"]:
        csv_path = os.path.join(defence_path, case, f"{defence}_out", "flowtool", "_ResultBoxes.csv")
        if os.path.exists(csv_path):
            total_invol = read_involume_sum(csv_path)
        else:
            print(f"📂 File not found: {csv_path}")
            total_invol = None

        results.append({
            "DefenceType": defence,
            "Case": case,
            "SumInVolumePast_m3": total_invol
        })

# Save to CSV
pd.DataFrame(results).to_csv(output_file, index=False)
print(f"✅ Summary saved to {output_file}")
