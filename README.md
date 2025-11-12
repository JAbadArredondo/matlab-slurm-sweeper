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
This tab contains all the specifications to determine the possible jobs to launch in the HPC. The available options are:
| Field | type | Description|
|------|-----|--------------|
| Ignore State | on/off | Ignores occupation state of the nodes in the HPC cluster and assumes all nodes are *idle*. Enabling this option directly overrides the *Use Mixed* option (see below). |
| Use Mixed | on/off | If enabled, the program will use the available resources in nodes that have *mixed* status (not completely filled). |
| Fill Nodes | on/off | If enabled, the program will assign free CPUs (that couldn't be assigned to a new job due to insufficient memory or CPU count) to existing available jobs, increasing resources. |
| Random Distrib | on/off | If enabled, the available jobs are shuffled in order. By default the jobs are sequentially ordered by compute node.|
| Bigger First | on/off | If enabled, the job list is ordered by decreasing number of CPUs assigned to each job. |
| Prefered CPUs | integer | Default number of CPUs to assign to each job. |
| Min. CPUs | integer | If insufficient CPUs to assign the preferred number of CPUs to a job, this stablishes the minimum number of CPUs acceptable to be assigned to a job. |
| Minimum Memory | numeric | Minimum amount of total memory (in MB) that has to be reserved for a given job. |
| Delete Queues | string | Comma-separated list of the queues that the user may want to exclude from the job generation. By default, the program generates possible jobs to fill the complete cluster. To see the Queues that exist in the cluster, I implement the *List Queues* button. |
| Delete Nodes | string | Comma-separated list of the compute nodes that the user may want to exclude from the job generation. By default, the program generates possible jobs to fill the complete cluster. To see the Nodes that exist in the cluster, I implement the *List Nodes* button. |

**Note about the behavior regarding minimum resources**: By default the program checks whether the most astringent limitation is placed on #CPU or total Memory, and increases the resource assignment to the counterpart, redistributing the excess, making the most of the cluster resources. 

A series of buttns are provided to help setting up the resource allocation and limits. These are: 
| Button | Effect | 
|------|-----|
| Cluster State | on/off | 
| List Queues | on/off | 
| List Nodes | on/off | 
| Enumerate Possible Jobs | on/off | 

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
