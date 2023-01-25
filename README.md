# Electric_vehicle_static_dynamic_models

This repository includes all the files necessary to perform the simulations included in the
paper "Static and Dynamic Load Models of Electric Vehicles connected to Fast Charging Stations".
The simulator used to perform the simulations is PAN. For any inquiry and if help is required with 
the software to replicate the results, please feel free to contact me at davide.delgiudice@polimi.it


The repository includes files with different extensions:
- va: includes objects defined with verilogA.
- txt: includes text files.
- dc: includes DC solutions of the circuits to be simulated (which could be used as initial guess 
for sweep analyses).
- mod: includes subcircuit definition.
- pan: actual files to me simulated.


The .pan files can be described as follows:
- charge_comparison: allows generating the data required to make the plots in Fig. 6 (full charge of
an electric vehicle (EV) with different Li-Ion cathode chemistries and charging modes).
- zip_retrieval: allows generating the data required to make the plots in Fig. 8 (static load
models for EV with different Li-Ion cathode chemistries and charging modes).
- overload_static: allows generating the data required to make the plots in Fig. 9 (impact of
different static load models on the IEEE14 system modified by adding EV fleets). 
- dyn_retrieval_VF and dyn_retrieval_TRAN: allow generating the data required to make the plots in 
Fig. 10 (derivation of a dynamic load for EVs based on vector fitting and its validation). 
- overload_dynamic: allows generating the data required to make the plots in Fig. 11 (impact of
different dynamic load models on the IEEE14 system modified by adding EV fleets). 
