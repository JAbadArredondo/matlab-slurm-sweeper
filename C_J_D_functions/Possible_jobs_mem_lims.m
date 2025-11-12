function P_jobs=Possible_jobs_mem_lims(Cell_state_cluster,Pref_Cores,Min_Cores,MinMemTot,Ignore_Cluster_Load,fill_nodes)

% Cell_state_cluster=Cellf;
% Pref_Cores=PrefCPU;
% Min_Cores=MinCPU;
% %MinMemTot
% Ignore_Cluster_Load=Ignore_state;

%I change the order, before it was
%-cpus - memory - node, and now it is:
%- queue -node -cpus -memory

P_jobs={};

for i=1:size(Cell_state_cluster,1)
    core_data=split(Cell_state_cluster{i,3},'/');
    T_Cores=str2double(core_data{4});
    if Ignore_Cluster_Load
        A_Cores=T_Cores;
    else
        A_Cores=str2double(core_data{2});
    end

    queue=Cell_state_cluster{i,1};
    node=Cell_state_cluster{i,2};

    Memory=str2double(Cell_state_cluster{i,4});

    mempcpu=round(0.95*(Memory/T_Cores)/1e3)*1e3;

    %Lets make it easier:
    % If MinMemTot==0, assume we are CPU bound like before.
    % If MinMemTot>0, then we are asking for memory bound processes.
    % Look for the total number of jobs that one can have with this
    % memory, and divide the CPUS between these many jobs. If the
    % number of CPUs fall below the minCPU threshold, trigger CPU bound
    % process.

    if MinMemTot>0 %If memory minima is required
        %Number of possible jobs being Memory Bound.
        N_jobs_mem_lim=floor(Memory./MinMemTot);
        %Divide the CPUs as equally as possible between all different
        %Memory-bound Jobs
        CPU_dist_mem_bound=floor((A_Cores+N_jobs_mem_lim-1:-1:A_Cores-1)./N_jobs_mem_lim);
        CPU_dist_mem_bound=CPU_dist_mem_bound(1:end-1);
        %Distribute total memory of the node across the jobs with a safety
        %factor of 5%
        mempcpu_dist_mem_bound=0.95*(Memory./N_jobs_mem_lim)./CPU_dist_mem_bound;
        mempcpu_dist_mem_bound=round(mempcpu_dist_mem_bound./1e3,3).*1e3;
    end

    %Number of possible jobs being CPU Bound.
    NJ_Pref_CPU=floor(A_Cores/Pref_Cores); %# Jobs PrefCPU
    NJ_Min_CPU=floor((A_Cores-NJ_Pref_CPU.*Pref_Cores)/Min_Cores); %# Jobs >MinCPU

    leftover_cpus=A_Cores-NJ_Pref_CPU.*Pref_Cores-NJ_Min_CPU.*Min_Cores;

    %Get the corresponding CPU list of possible Jobs
    CPU_dist_CPU_bound=repelem(Pref_Cores,NJ_Pref_CPU);
    if NJ_Min_CPU>0
        tmp=A_Cores-sum(CPU_dist_CPU_bound);
        CPU_dist_CPU_bound=[CPU_dist_CPU_bound,tmp];
    end

    %If any left-over Cpus from distribution, and fill_nodes is active,
    %redistribute the available cores over jobs.
    if and(fill_nodes,leftover_cpus>0)
        if length(unique(CPU_dist_CPU_bound))>=2 %2 kinds of jobs  generated:
            %equilibrate protocol (This should not be reached)

        elseif length(unique(CPU_dist_CPU_bound))==1
            %Then only Pref_Cpu jobs are issued, and not enough
            %leftover CPUS to reach min_cpu.

            extra_cont_CPU=floor((leftover_cpus+length(CPU_dist_CPU_bound)-1:-1:leftover_cpus-1)./length(CPU_dist_CPU_bound));
            extra_cont_CPU=extra_cont_CPU(1:end-1);
            CPU_dist_CPU_bound=CPU_dist_CPU_bound+extra_cont_CPU;
        end
    end

    %mempcpu=floor((Memory/T_Cores)/1000)*1000;
    %Some queues were running out of memory
    mempcpu_dist_cpu_bound=repelem(mempcpu,length(CPU_dist_CPU_bound));

    %Define a flag to indicate whether to distribute the compute power
    %according to memory bound or CPU bounds, or skip node altogether
    flag_skip=false;
    flag_Memory_bound=false;

    if MinMemTot==0
        flag_Memory_bound=false;
        limit_str='CPU_bound';
    elseif and(MinMemTot>0,N_jobs_mem_lim>0) %i.e. if required memory fits in the node
        if min(CPU_dist_mem_bound)<Min_Cores
            flag_Memory_bound=false;
            limit_str='CPU_bound';
        elseif min(CPU_dist_mem_bound)>=Min_Cores
            flag_Memory_bound=true;
            limit_str='RAM_bound';
        end
    elseif and(MinMemTot>0,N_jobs_mem_lim==0)%i.e. required minimum memory but node doesn't have it
        flag_skip=true;
    end

    flag_CPU_bound=~flag_Memory_bound;

    if flag_skip
        cpu_l=[];
        ram_l=[];
    elseif flag_Memory_bound
        cpu_l=CPU_dist_mem_bound;
        ram_l=mempcpu_dist_mem_bound;
    elseif flag_CPU_bound
        cpu_l=CPU_dist_CPU_bound;
        ram_l=mempcpu_dist_cpu_bound;
    end

    for j=1:length(cpu_l)
        P_jobs=[P_jobs;{queue,num2str(cpu_l(j)),num2str(ram_l(j)),node,limit_str}];
    end

end

end

