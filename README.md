Optimal Design of Coastal Defences using SPH

MSc Advanced Aerospace Engineering Dissertation | University of Liverpool
1. Overview

This project investigates the hydrodynamic performance of various coastal defence structures using Smoothed Particle Hydrodynamics (SPH). As sea levels are projected to rise by up to 1.1m by 2100, this study evaluates the trade-offs between wave overtopping prevention and structural horizontal loading to identify an optimal hybrid design.
2. Technical Methodology

    Numerical Framework: Implemented using DualSPHysics (Weakly Compressible SPH).

    Physics Kernels: Utilized the Wendland kernel with a Symplectic integration scheme for high-order accuracy.

    Boundary Conditions: Applied Modified Dynamic Boundary Conditions (mDBC) to simulate a 2D numerical wave flume.

    Validation: Benchmarked against analytical linear wave theory and published experimental data, achieving an average error of <2%.

3. Case Studies Analyzed

I modeled and compared four distinct geometries:

    Vertical Seawall: High loading, minimal overtopping.

    Impermeable Revetment (Sloped): Reduced loading, excessive overtopping.

    Hybrid A (Revetment + Parapet): Parapet crest 0.1m above Still Water Level (SWL).

    Hybrid B (Revetment + Parapet): Parapet crest at SWL.

4. Key Findings

    The Parapet Effect: Adding a vertical parapet to a revetment significantly reduces overtopping without the massive structural load of a full seawall.

    Optimization: Hybrid Structure A was identified as the optimal configuration, balancing the energy dissipation of the slope with the reflection capabilities of the parapet.

    Industry Standards: Validated results against the EurOtop (2018) manual for sea defense design.

5. Repository Structure

    /Case_Files: XML input files for DualSPHysics cases.

    /Visuals: Post-processed plots of velocity fields and loading curves.

    /Post-Processing_Scripts: Automation and extraction scripts used in the project. 

    ≈Final_Report.pdf: Full 50-page technical dissertation
