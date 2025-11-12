# matlab-slurm-sweeper
> Distributed parameter sweep manager for MATLAB + Slurm clusters

This software suite is designed to send parametric sweeps to distributed clusters that use Slurm as a queue manager, and then fetch the results. 

## 📖 Overview
This program attempts to solve the problem of spreading a parametric sweep of a given program across different computing nodes of a cluster. This suite contains two main programs, that work through a GUI: 
- ClusterJobDistributiorUI: which handles resource availability, job generation, parameter assignation, file population in the remote cluster, and job inicialization.  
- ClusterUpdateDataSyncUI: which once the jobs are done, serves to fetch the desired output files from the parametric sweep.
For a broader explanation if capabilities see the next sections.

## ⚙️ Features
- GUI-based submission and synchronization
- Automatic Slurm script generation with keyword capabilities
- Resource-aware job management
- Flexible parameter sweep generation
- Ability to save configurations
- Ability to directly batch jobs from GUI
- Result synchronization via scp
- Ability to update on the fly for ongoing sweeps
- Multiple sweeps can be updated to multiple local folders
- Configurable for multiple remote clusters

## 📂 Repository Structure
| File | Description |
|------|--------------|
| `ClusterJobDistributorUI.m` | GUI for configuring and launching parameter sweeps |
| `ClusterUpdateDataSyncUI.m` | GUI for fetching results |
| `/C_J_D_functions/` | Auxiliary functions |
| `ssh2_v2_m1_r7.zip` | SSH and file-handling utilities implemented by David Freedman in [^1]|


## 🧩 Installation
To use the program, download the contents of the repository to the desired destination folder, where the program will be executed. It is advised that all the files are kept within its own folder (e.g. ./matlab-slurm-sweeper/). Finally unzip the contents of the ssh2_v2_m1_r7.zip to a folder with the same name and the different programs can be called from a matlab instance. 

## 🚀 Usage
In this section I describe the usage and GUI interface of the different programs. Both GUIs are structured using tab groups. For each of the programs I will now explain the usage and functionality of the different parts of the GUI. 

### **ClusterJobDistributiorUI**: Creating and Launching Jobs 
This program is designed to automatize the workflow of creating and running a parametric sweep in a HPC cluster. For this, the program checks a HPC's state, and creates a list of available jobs depending on user specification and hardware limitations. Then, it uses the provided parameter lists and generates appropriate parameter combinations (as specified) and assigna a job slot to each parameter combination. Then it creates a unique folder for each parameter combination and uploads:
- a parameter file: containing the parameter values of the program run.
- a slurm job script, which has been particularized for the job parameters and user-defined batch command.
- The files needed to run the program, as specified by the user.

Then, the program contains functionality to directly batch all the created jobs. 
To configure this workflow, the GUI is structured in different tabs. In what follows, I list the different tabs and explain the different fields: 
#### <ins> Cluster Settings </ins>
This tab contains the details to configre the ssh connection to the HPC cluster. You can specify the Hostname, username and your password. Note that Hostname and Username will be stored between sessions, but the password will not. 

Once the details are introduced, you can hit the *Test Connection* button, to test that the connection is possible. 

#### <ins> Jobs Configuration </ins>


### **ClusterUpdateDataSyncUI**: Synchronizing Results,
## Requirements
Written in Matlab 2025b and tested in a , Slurm, etc.

## Example Workflow
Small demonstration or screenshots.

## Future Work
Future versions will include functionality to monitor and manage pending and running jobs, by cancelling them or re-launching them with different characteristics. 

## Author and Citation
Your name, contact, and note about future DOI.

## License
License badge and statement.


[^1]: David Freedman (2025). SSH/SFTP/SCP For Matlab (v2) (https://es.mathworks.com/matlabcentral/fileexchange/35409-ssh-sftp-scp-for-matlab-v2), MATLAB Central File Exchange. Accessed 12 November, 2025.
