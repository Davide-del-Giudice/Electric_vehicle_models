# Electric_vehicle_static_dynamic_models

This repository includes all the files necessary to perform the simulations included in the
paper "Equivalent Model of Electric Vehicles with Fast Chargers for Static and Dynamic Grid Studies".
The simulator used to perform the simulations is PAN. For any inquiry and if help is required with 
the software to replicate the results, please feel free to contact me at davide.delgiudice@polimi.it

The repository includes files with different extensions:
- va: includes objects defined with verilogA.
- txt: includes text files.
- dc: includes DC solutions of the circuits to be simulated (which could be used as initial guess 
for sweep analyses).
- pan: actual files to me simulated.

The .pan files can be described as follows:
- k1: allows generating the data required to make the plots in Fig.4. All the results can be quickly generated through the "run_static_EV_sweep" file, which simulates each case considered in the figure.
- charge_comparison: allows generating the data required to make the plots in Fig. 5 and 6. All the results can be quickly generated through the "run_charge" file, which simulates each case considered in the figure.
- ieee14: allows generating the data required to make the plots in Fig. 8. All the results can be quickly generated through the "run_dynamic_fleet_EV" file, which simulates each case considered in the figure.

Warning: before executing these scripts create these three folder in the same directory: "SWEEP_FLEET_EV", "CHARGE_COMPARISON", and "DYN_OVERLOAD_EV".

Concerning OpenDSS, all the files needed to simulate the k1 feeder in the same conditions are available in the "OpenDSS" folder.

Lastly, the Mathematica notebooks "EV_static" and "EV_dynamic" shows how to derive the equations of the static (blocks 2, 3, 5 of Figure 2) and the transfer functions in block 6 of Fig. 6 employed by the proposed EV model. 




