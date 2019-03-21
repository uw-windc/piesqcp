# piesqcp

This is an illustrative example of the PIES model originally written by William Hogan (1975). Energy policy models for Project Independence, Computers and Operations Research 2.

The .gms file is provided for GAMS users and a translated version of the .gms file is provided in Julia/JuMP format (.jl).  Data from the .gms file is output to a GDX container and then converted into a JSON file with gdx2json.py.  The Julia/JuMP model then reads the data directly in from the JSON file.

The user will need to add the JuMP, JSON, and Ipopt packages to their Julia installation. It is assumed that the user has Julia 1.1.0.

In order to run the gdx2json.py script the user will need to install the GAMS Python API... and may need to create a Python 3 environment with the following .yml file.  Conda was used as the Python package manager and is recommended to create this environment.  Information on how to import this environment is available here: https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#sharing-an-environment

The solution between the GAMS model and the Julia/JuMP model has been verified to be the same.
