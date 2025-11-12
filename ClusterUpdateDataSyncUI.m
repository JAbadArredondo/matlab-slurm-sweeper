
function ClusterUpdateDataSyncUI
import matlab.ui.control.*
import matlab.ui.container.*

addpath('.\ssh2_v2_m1_r7\')
addpath('.\C_J_D_functions\')


%% --- Main Figure ---
screenSize = get(0, 'ScreenSize');
fig = uifigure('Name', 'Cluster Result Sync', ...
    'Position', [0.05*screenSize(3), 0.1*screenSize(4), screenSize(3)/2, screenSize(4)*(2/3)]);
%Autosaves current state on closing
fig.CloseRequestFcn = @(src,event) closeFigure(src);

gl = uigridlayout(fig, [2, 1]);
gl.RowHeight = {347, '1x'};  % top row: tabs, bottom: shared log
gl.ColumnWidth = {'1x'};

% --- Tab group for all the different cluster settings ---
tg = uitabgroup(gl);
tg.Layout.Row = 1;

% --- Shared Log Area (visible in all tabs) ---
sharedLog = uitextarea(gl, ...
    'Editable', 'off', ...
    'Value', {'--- Log initialized ---'}, ...
    'FontName', 'Consolas', ...
    'FontSize', 11);
sharedLog.Layout.Row = 2;

%% ------------------ CLUSTER SETTINGS TAB ------------------
tab1 = uitab(tg, 'Title', 'Cluster Settings');
clusterLayout = uigridlayout(tab1, [5, 2]);
clusterLayout.RowHeight = {22, 22, 22, 22, '1x'};
clusterLayout.ColumnWidth = {'fit', '1x'};

lbl = uilabel(clusterLayout, 'Text', 'Hostname:'); lbl.Layout.Row = 1; lbl.Layout.Column = 1;
hostnameField = uieditfield(clusterLayout, 'text', 'Value', 'cluster.direction');
hostnameField.Layout.Row = 1; hostnameField.Layout.Column = 2;

lbl = uilabel(clusterLayout, 'Text', 'Username:'); lbl.Layout.Row = 2; lbl.Layout.Column = 1;
usernameField = uieditfield(clusterLayout, 'text', 'Value', 'user');
usernameField.Layout.Row = 2; usernameField.Layout.Column = 2;

lbl = uilabel(clusterLayout, 'Text', 'Password:'); lbl.Layout.Row = 3; lbl.Layout.Column = 1;
passwordField = uieditfield(clusterLayout, 'text');
passwordField.Layout.Row = 3; passwordField.Layout.Column = 2;

testConnBtn = uibutton(clusterLayout, 'Text', 'Test Connection',...
    'ButtonPushedFcn', @(~,~)testClusterConnection());
testConnBtn.Layout.Row = 4; testConnBtn.Layout.Column = 1;
dummy = uilabel(clusterLayout, 'Text', ''); dummy.Layout.Row = 4; dummy.Layout.Column = 2;

%% ------------------ File Management Tab ------------------
tab2 = uitab(tg, 'Title', 'File Management');

fileLayout = uigridlayout(tab2, [5, 3]);
fileLayout.RowHeight = {22, 22, 22, 22, '1x', 30};
fileLayout.ColumnWidth = {'fit','1x','fit'};
fileLayout.RowSpacing = 8;
fileLayout.Padding = [10 10 10 10];

% Base folders
lbl=uilabel(fileLayout, 'Text', 'Base Remote Folder:');
lbl.Layout.Row = 1;
remoteBaseField = uieditfield(fileLayout, 'text', 'Value', '/remote/path/');
remoteBaseField.Layout.Row = 1;
remoteBaseField.Layout.Column = [2 3];

lbl=uilabel(fileLayout, 'Text', 'Base Local Folder:');lbl.Layout.Row = 2;
localBaseField = uieditfield(fileLayout, 'text', 'Value', '/local/path/');
localBaseField.Layout.Row = 2;
localBaseField.Layout.Column = [2 3];

%Files to fetch
lbl=uilabel(fileLayout, 'Text', 'Files to fetch:'); lbl.Layout.Row = 3;
FileToFetchField = uieditfield(fileLayout, 'text', 'Value', 'example_*_parts.*',...
    'Tooltip',['Indicate the name of the files to fetch from the cluster. ',...
    'You can use wildcards to indicate the file names, and these will be ',...
    'matched to any existing files in the target remote folders. ',...
    'You can specify a list of comma separated filenames and all will be ',...
    'fetched.']);
FileToFetchField.Layout.Row = 3;
FileToFetchField.Layout.Column = 2;

NameAppendToggle = uicheckbox(fileLayout, ...
    'Text', 'Append Parent Folder', ...
    'Value', false, ...
    'Tooltip', ['If enabled, when copying the target files it appends the ',...
    'name of the particular origin folder to the name of the file. Useful ',...
    'if all files to fetch have exactly the same name.']);
NameAppendToggle.Layout.Row = 3;
NameAppendToggle.Layout.Column = 3;

% Toggle multiple target folders
multiToggle = uicheckbox(fileLayout, ...
    'Text', 'Multiple target folders', ...
    'Value', false, ...
    'ValueChangedFcn', @(cb, event) toggleMultiMode(cb),...
    'Tooltip', 'Enable table below to specify multiple folder pairs');
multiToggle.Layout.Row = 4;
multiToggle.Layout.Column = [1 3];

% Table
subfolderTable = uitable(fileLayout, ...
    'ColumnName', {'Remote Subfolder', 'Local Target'}, ...
    'ColumnEditable', [true true], ...
    'Data', {}, ...
    'Enable', 'off');
subfolderTable.Layout.Row = 5;
subfolderTable.Layout.Column = [1 3];

auxGrid = uigridlayout(fileLayout, [1, 2]);
auxGrid.Layout.Row = 6;
auxGrid.Layout.Column = [1 3];      % span full width of fileLayout
auxGrid.ColumnWidth = {'1x', '1x'}; % equal widths
auxGrid.RowHeight = {'1x'};
auxGrid.Padding = [0 0 0 0];
auxGrid.ColumnSpacing = 8;

% Create buttons as children of the auxGrid (store handles)
addBtn = uibutton(auxGrid, 'Text', '➕ Add Row', 'Enable', 'off',...
    'ButtonPushedFcn', @(btn,event) addRow());
addBtn.Layout.Row = 1; addBtn.Layout.Column = 1;

removeBtn = uibutton(auxGrid, 'Text', '➖ Remove Selected', 'Enable', 'off',...
    'ButtonPushedFcn', @(btn,event) removeRow());
removeBtn.Layout.Row = 1; removeBtn.Layout.Column = 2;

%% --------------- Update and download tab ----------------------
tab3 = uitab(tg, 'Title', 'Execution');

execLayout = uigridlayout(tab3,[5,2]);
execLayout.RowHeight = {30,80,30,30,30};
execLayout.ColumnWidth = {'fit','1x'};
execLayout.RowSpacing = 8;

% --- Section title ---
batchTitle = uilabel(execLayout, ...
    'Text','Data syncying', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'HorizontalAlignment','left');
batchTitle.Layout.Row = 1;
batchTitle.Layout.Column = [1,2];

TextDescription=uitextarea(execLayout,'Value',{['This goes through all the folders ',...
    'especified in the Remote Path and downloads the files with names that ',...
    'pattern-match the specified target file name. Then copies all these ',...
    'files to a remote folder, compresses it, downloads it to the target ',...
    'local folder, and cleans the remote and local temporary data.'],...
    ['In this process, the code checks if any slurm*.out file is in the ',...
    'folder, if so, it checks if the corresponding job is running and if ',...
    'so, updates the folder before copying the files.']},'Editable','off');
TextDescription.Layout.Row = 2;
TextDescription.Layout.Column = [1,2];

% --- Run full pipeline button ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   I want a modifyier to select whether I run an additional uwd command to
%   fetch the running results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Toggle multiple target folders
ToggleUpdate = uicheckbox(execLayout, ...
    'Text', 'Update folders before sync.', ...
    'Value', false,...
    'Tooltip', 'Updates folders so that the program downloads updated data. Note that if models are large this will create a lot of data traffic. Making the data sync slow. Only activate this option if there are few folders or the simulation files are not heavy.');
ToggleUpdate.Layout.Row = 3;
ToggleUpdate.Layout.Column = 1;

runPipelineBtn = uibutton(execLayout,'Text','Run data sync.',...
    'ButtonPushedFcn',@(btn,event) Run_Full_pipeline());
runPipelineBtn.Layout.Row = 3;
runPipelineBtn.Layout.Column = 2;

% --- Section title ---
batchTitle = uilabel(execLayout, ...
    'Text','Save/Load configuration', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'HorizontalAlignment','left');
batchTitle.Layout.Row = 4;
batchTitle.Layout.Column = [1,2];


% Create buttons as children of the auxGrid (store handles)
SaveConfigBtn = uibutton(execLayout, 'Text', 'Save Configuration',...
    'ButtonPushedFcn', @(btn,event) BrowseandSaveConfig(),...
    'Tooltip','This prompts a UI to save the current configuration to a particular file location. By default it starts at the current LocalPath.');
SaveConfigBtn.Layout.Row = 5; SaveConfigBtn.Layout.Column = 1;

LoadConfigBtn = uibutton(execLayout, 'Text', 'Load Configuration',...
    'ButtonPushedFcn', @(btn,event) BrowseandLoadConfig(),...
    'Tooltip','This prompts a UI to load a configuration. By default it starts at the current LocalPath.');
LoadConfigBtn.Layout.Row = 5; LoadConfigBtn.Layout.Column = 2;





%% ------------ Load last session if it exists -----------------------
runningFile = mfilename('fullpath');
[folder, ~, ~] = fileparts(runningFile);
lastCfgFile = fullfile(folder, 'last_config_sync.mat');

if isfile(lastCfgFile)
    try
        cfg = load(lastCfgFile);
        applyConfig(cfg);
        sharedLog.Value = [sharedLog.Value; {['[Info] Loaded last session config from ' lastCfgFile]}];
    catch ME
        sharedLog.Value = [sharedLog.Value; {['[Warning] Could not load last session config: ' ME.message]}];
    end
end


%% ------------------ CALLBACKS ------------------

%Logging actions:
    function logToLog(msg)
        t = datestr(now,'[HH:MM:SS]');
        sharedLog.Value = [sharedLog.Value; {[t ' ' msg]}];
        drawnow;
    end

%-----------------------------Cluster calling and quering functions--------
    function ssh2_conn=EstablishBasicConnection()
        host = hostnameField.Value;
        user = usernameField.Value;
        pass = passwordField.Value;

        % --- Basic validation ---
        if isempty(host) || isempty(user) || isempty(pass)
            logToLog('[Error] Please fill in hostname, username, and password before testing.');
            return;
        end

        try
            % --- Establish SSH connection ---
            logToLog(sprintf('[Connecting] Trying SSH to %s@%s ...', user, host));
            ssh2_conn = ssh2_config(host, user, pass);

        catch ME
            logToLog(sprintf('[Error] SSH connection failed: %s', ME.message));
        end

    end

    function testClusterConnection()

        try
            % --- Establish SSH connection ---
            ssh2_conn=EstablishBasicConnection();

            % --- Run a simple command to test connectivity ---
            [ssh2_conn, result] = ssh2_command(ssh2_conn, 'hostname');
            hostnameStr = strtrim(strjoin(result, ' '));
            logToLog(sprintf('[Success] Connected to %s', hostnameStr));

            % --- Close connection cleanly ---
            ssh2_close(ssh2_conn);

        catch ME
            logToLog(sprintf('[Error] SSH connection failed: %s', ME.message));
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function Run_Full_pipeline()

        %Folders in which the simulations are running

        if multiToggle.Value
            s=size(subfolderTable.Data,1);
            local_folders=cell(1,s);
            remote_folders=cell(1,s);
            for i=1:s
                local_folders{i}=[localBaseField.Value,subfolderTable.Data{i,2},'\'];
                remote_folders{i}=[remoteBaseField.Value,subfolderTable.Data{i,1},'/'];
            end
        elseif ~multiToggle.Value
            local_folders={localBaseField.Value};
            remote_folders={remoteBaseField.Value};
        end

        %Create folders if they dont exist:
        for i=1:length(local_folders)
            if ~exist(local_folders{i},'dir')
                mkdir(local_folders{i})
            end
        end
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Preprocess the files that you want to get on each of the folders:
        target_files=split(FileToFetchField.Value,',');
        %Make this string into a cell of patterns by using split(,) and trim
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        H = multiwaitbar(2,[0 0 0 1],{'Please wait','Please wait'});
        
        %Establish connection to cluster
        ssh2_conn=EstablishBasicConnection();
        
        for j=1:length(remote_folders)

            %Get the names of the numeric subfolders in the folder to
            %update.
            [ssh2_conn,folders] = ssh2_command(ssh2_conn, ['cd ',remote_folders{j},';ls -d */'],0);

            %Create temp folder to dump all the desired data into
            tmp_folder_name='tmp_data_fetch_folder';
            [ssh2_conn] = ssh2_command(ssh2_conn,['mkdir ',remote_folders{j},tmp_folder_name,'/'],0);

            %Remove Save_run_data from the list
            folders=folders(~contains(folders,tmp_folder_name));

            t_iavg=0;
            %Loop through folders in each of the target remote folders.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %
            % This implementation is extremelly slow because it loops
            % through everything somewhat unnecesarily. Future
            % implementations will avoid issuing separated ssh2_commands.
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for i=1:length(folders)
                %Display Text in waitbar
                t_rem=(length(folders)-(i-1))*t_iavg;
                text_1=['Updating: ',remote_folders{j}];
                text_1=strrep(text_1,'_',' ');
                [text_1,text_2]=format_string_waitbar(text_1,folders{i},t_rem);
                multiwaitbar(2,[(j-1)/length(remote_folders),(i-1)/length(folders)],{text_1,text_2},H);
                tic;
                
                %On each of these sub-folders, first, check if the user
                %indicated that update was desired. If so, update the
                %folder contents:
                if ToggleUpdate.Value
                    %Note that this requires that the name of the .out file
                    %created by slurm is named like this.
                    ssh2_conn = ssh2_command(ssh2_conn, ['cd ',remote_folders{j},folders{i},...
                        '; yes | uwd $(ls slurm*.out);'],0);
                end

                %Once the folder has been updated, locate all the files
                %that match the wildcards
                files_To_Copy={};
                for k=1:length(target_files)
                    [ssh2_conn,tmp_files] = ssh2_command(ssh2_conn, ['cd ',remote_folders{j},folders{i},...
                        '; ls ',target_files{k}],0);
                    %If we have coincidences:
                    if any(cellfun(@(s) ~isempty(s),tmp_files))
                        files_To_Copy=[files_To_Copy;tmp_files];
                    end
                end
                
                files_To_Copy_Dest=cell(size(files_To_Copy));
                %If the names of all the desired files are identical, then
                %the Append farent Folder name option should be enabled.
                %This means we take the name of the folder from which we
                %are copying the data (Numeric), and append the number to
                %the end of the file name. 
                if NameAppendToggle.Value
                    folder_id=folders{i}(1:end-1); %Remove slash char.
                    for k=1:length(files_To_Copy)
                        %Extract name and extension. 
                        tmp=split(files_To_Copy{k},'.');
                        files_To_Copy_Dest{k}=[tmp{1},'_',folder_id,'.',tmp{2}];
                    end
                else
                    files_To_Copy_Dest=files_To_Copy;
                end
                
                %Now copy desired data from remote folder to target save
                %folder: 
                for k=1:length(files_To_Copy)
                    ssh2_conn = ssh2_command(ssh2_conn, ['cd ',remote_folders{j},folders{i},...
                        '; cp -f ',files_To_Copy{k},' ',remote_folders{j},tmp_folder_name,'/',files_To_Copy_Dest{k}],0);
                end

                t=toc;
                t_iavg=((i-1)*t_iavg + t)/i;

            end
            
            logToLog('Compressing remote data')
            %Change to parent directory and compress folder with all saved data
            [ssh2_conn,msg_tmp] = ssh2_command(ssh2_conn,...
                ['cd ',remote_folders{j},'; zip -r ',tmp_folder_name,'.zip ',tmp_folder_name],...
                0);

            %Download compressed data
            logToLog('Downloading compressed data:')
            [ssh2_conn,filestoscp] = ssh2_command(ssh2_conn, ['cd ',remote_folders{j},';ls ',tmp_folder_name,'.zip']);
            ssh2_conn = scp_get(ssh2_conn,filestoscp,local_folders{j},remote_folders{j});

            %Unzip downloaded data
            logToLog('Unziping data:')
            unzip([local_folders{j},tmp_folder_name,'.zip'],local_folders{j})
            movefile([local_folders{j},tmp_folder_name,'\*'],local_folders{j})

            %Cleanup
            logToLog('Cleanup')
            rmdir([local_folders{j},tmp_folder_name,'\'],'s')

            logToLog(sprintf('[Success] Synced data from Remote Folder: %s, to Local Folder: %s',...
                remote_folders{j},...
                local_folders{j}))

        end

        delete(H.figure)
        clear('H')

        logToLog('[Sucess] Complete update, closing ssh connection...')
        ssh2_conn = ssh2_close(ssh2_conn); %close connection when done
    end

    function [text_1,text_2]=format_string_waitbar(text_1,folder_name,t_rem)

        %Find slash closest to middle of string. Split in two and pad
        %shortest string.
        tmp_a=find(text_1=='/');
        [~,ind]=min(abs(length(text_1)/2-tmp_a));
        ind=tmp_a(ind);
        tmp_a=text_1(1:ind);l_a=ind;
        tmp_b=text_1(ind:end);l_b=length(text_1)-ind+1;
        %pad
        [size,ind]=max([l_a,l_b]);
        if ind==1
            %tmp_a bigger. Pad tmp_b
            pad=repmat(' ',[1,size-l_b]);
            tmp_b=[pad,tmp_b];
        elseif ind==2
            %tmp_b bigger. Pad tmp_a
            pad=repmat(' ',[1,size-l_a]);
            tmp_a=[tmp_a,pad];
        end
        text_1=[tmp_a;tmp_b];

        tmp_a=['Updating subfolder: ',folder_name];
        tmp_b=['Estimated time remaining: ',num2str(t_rem),' s'];
        [size,ind]=max([length(tmp_a),length(tmp_b)]);

        if ind==1
            %tmp_a bigger. Pad tmp_b
            pad=repmat(' ',[1,size-length(tmp_b)]);
            tmp_b=[tmp_b,pad];
        elseif ind==2
            %tmp_b bigger. Pad tmp_a
            pad=repmat(' ',[1,size-length(tmp_a)]);
            tmp_a=[tmp_a,pad];
        end
        text_2=[tmp_a;tmp_b];
    end

% function Run_Full_pipeline()
%     %Steps:
%     %1) Connect to the cluster and determine the number of jobs
%     %available according to User specifications
%     %2) Calculate the combinations of parameter runs. (Display a
%     %warning if the number of combinations is larger than available
%     %jobs)
%     %2b) Upload the simulation files
%     %3) Start Locally writing the parameter files and scripts
%     %corresponding to each job
%     %4) Compress all these files and upload them to the remote path.
%     %5) Decompress on the remote cluster, create folders for each run,
%     %and distribute parameter and script files to each folder
%     %6) Copy simulation files to each simulation folder
%
%     %1) Get cluster state and possible Jobs according to user
%     %specifications
%     [S_valid,lookout_queues]=getFilteredClusterState(false,false);
%     P_jobs=EnumeratePossibleJobs(S_valid,lookout_queues);
%
%     logToLog(sprintf('%d Jobs according to user specifications',size(P_jobs,1)));
%
%     %2) Get the run parameters:
%     [Candidates_sweep,Run_params]=getJobParams();
%     logToLog(sprintf('%d Parameter combinations',size(Run_params,1)));
%
%     %Test if number of simulations is larger than available job configurations
%     N_oc=ceil(size(Run_params,1)./size(P_jobs,1));
%     %If so, pad the list of possible jobs with itself so that it loops back
%     if N_oc>=1
%         logToLog('[Warning] More Jobs than available, your simulations will queue.');
%         P_jobs=repmat(P_jobs,[ceil(N_oc),1]);
%     end
%     %This allows to run the index over the list of parameter values.
%
%     %2b) Upload simulation file(s) to cluster
%     UploadModelToRemotePath()
%     logToLog('Uploaded simulation file.');
%
%     %3) Write all scripts and parameter files for the simulations:
%     %load in basis for script file:
%     fid = fopen('./base_slurm_jobscript.sh','r');
%     j = 1;
%     tline = fgetl(fid);
%     A{j} = tline;
%     while ischar(tline)
%         j = j+1;
%         tline = fgetl(fid);
%         A{j} = tline;
%     end
%     fclose(fid);
%
%     % Now, instead of parallelizing the upload process, lets use BASH to
%     % handle the redistribution process. To do so, I will generate locally all
%     % the parameter and scripts, and then tar them and upload them to the
%     % cluster all at once. This should be much much faster than sending them
%     % over one by one.
%
%     %I label each file by the destination folder in which I want them.
%
%     %Create the list of job ids and detination folders to run them.
%     job_number_init=1; job_number=job_number_init+(0:size(Run_params,1));
%     folder_number_init=startFolderField.Value; folder_number=folder_number_init+(0:size(Run_params,1));
%
%     %Create local folder to generate all the files:
%     tmp_local_path='tmp_scripts_and_params';
%     mkdir(['./',tmp_local_path,'/'])
%
%     %Aux strings to build filenames during loop:
%     js_parts=split(ScriptFileField.Value,'.');
%     param_parts=split(ParameterFileField.Value,'.');
%
%     %Create waitbar
%     f=waitbar(0,'Creating folders for simulations');
%     tavg=0;
%     trest=Inf;
%
%     %Loop through the different parameter combinations, modify the
%     %slurm script for each job, and write the parameter file.
%     for i=1:size(Run_params,1)
%         waitbar(i/size(Run_params,1),f,{['Creating simulation files ',num2str(i),'/',num2str(size(Run_params,1))];['Estimated time remaining : ',num2str(trest),' s']});
%         tic
%
%         %The values of each parameter are in the same order as in
%         %Candidates_sweep, because it is the order used by Param_sweep_Gen to
%         %make the grid of values.
%         jobscript_name=[js_parts{1},'_',num2str(folder_number(i)),'.',js_parts{2}];
%         paramfile_name=[param_parts{1},'_',num2str(folder_number(i)),'.',param_parts{2}];
%
%         %Save the run parameters
%         fid_param=fopen(['./',tmp_local_path,'/',paramfile_name],'w');
%         for k=1:length(Candidates_sweep)
%             fprintf(fid_param,[Candidates_sweep{k},' %d\n'],Run_params{i,k});
%         end
%         fclose(fid_param);
%
%         %Give job a name
%         job_name=sprintf('N%d/%d',job_number(i),size(Run_params,1));
%
%         % %Write the corresponding script
%         writescript(job_name,P_jobs(i,:),A,clusterCmdArea.Value,...
%             ['./',tmp_local_path,'/'],jobscript_name)
%
%         t=toc;
%         tavg=(t+(i-1)*tavg)/i;
%         trest=tavg*(size(Run_params,1)-i);
%     end
%
%     waitbar(1,f,'Compressing and uploading');
%
%     % 4) Compress the temporal folder with all the scripts and
%     % instructions and upload it to the remote path
%     tmp_local_path_tar=[tmp_local_path,'.tar'];
%     tar(tmp_local_path_tar,tmp_local_path)
%
%     %Move compressed files to cluster
%
%     % --- Parameters for SSH connection ---
%     host = hostnameField.Value;
%     user = usernameField.Value;
%     pass = passwordField.Value;
%     model=modelFileField.Value;
%     LocalPath=localPathField.Value;
%     RemotePath=remotePathField.Value;
%
%     % --- Basic validation ---
%     log_file_flag= isempty(LocalPath) || isempty(RemotePath);
%     log_login_flag=isempty(host) || isempty(user) || isempty(pass);
%
%     if log_login_flag
%         logToLog('[Error] Please fill in hostname, username, and password before testing.');
%         return;
%     elseif log_file_flag
%         logToLog('[Error] Please fill in Simulation file, local and remote paths for model upload.');
%         return;
%     end
%
%     %Establish connection to cluster
%     ssh2_conn = ssh2_config(host, user, pass);
%
%     logToLog(sprintf('[Uploading] parameter and simulation files to %s', RemotePath));
%     ssh2_conn = sftp_put(ssh2_conn, tmp_local_path_tar, RemotePath, pwd, tmp_local_path_tar);
%
%     % 5) Unpack the compressed data, and then distribute the different
%     % simulation files across the different folders
%
%     %unpack and remove the compressed data
%     ssh2_conn = ssh2_command(ssh2_conn,['cd ',RemotePath,'; tar -xf ',tmp_local_path_tar,'; rm ',tmp_local_path_tar],0);
%
%     waitbar(1,f,'Sort and copying');
%     %Distribute files across different folders, this is all done from a
%     %single bash command. It goes as follows:
%     % It goes to the folder where all the params and script files are.
%     % It then gets all the different individual ids of the different files
%     % It then uses these identifiers to create a folder and move all the files
%     % to the corresponding folder, removing the identifyer.
%     % Then it copies the associated simulation file to such folder.
%     str_remote_files='';
%     %In case of several files to copy to each folder, this will append the
%     %instruction with each of the different files
%     model = strtrim(strsplit(model, ','));
%     for j=1:length(model)
%         str_remote_files=[str_remote_files,'[ -f "$target/',model{j},'" ] || cp ../',model{j},' "$target/"; '];
%     end
%
%     Cluster_cmd_create_folds_move_params_and_sim_files=[...
%         'cd ',RemotePath,tmp_local_path,'/ && ',...
%         'for f in *_*.*; do ',...
%         '[ -e "$f" ] || continue; ',...
%         'id=$(echo "$f" | sed -E ''s/.*_([0-9]+)\..*/\1/''); ',...
%         'base=$(echo "$f" | sed -E ''s/(.*)_[0-9]+(\..*)/\1\2/''); ',...
%         'target=../$id; ',...
%         'mkdir -p "$target"; ',...
%         'mv "$f" "$target/$base"; ',...
%         str_remote_files,...
%         'done'];
%     ssh2_conn = ssh2_command(ssh2_conn,Cluster_cmd_create_folds_move_params_and_sim_files,0);
%
%     waitbar(1,f,'Cleanup');
%
%     %Remove empty temporary folder
%     ssh2_conn= ssh2_command(ssh2_conn,['cd ',RemotePath,'; ',...
%         'rm -r ',tmp_local_path],0);
%     %Delete current param and jobscript
%     rmdir(tmp_local_path, 's')
%     delete(['./',tmp_local_path_tar])
%
%     % --- Close connection cleanly ---
%     ssh2_close(ssh2_conn);
%     logToLog('[Success] Files correctly uploaded and simulation folders created');
%     close(f);
% end

% -----------------------------GUI actions functions------------------------

    function toggleMultiMode(cb)
        if cb.Value
            subfolderTable.Enable = 'on';
            addBtn.Enable = 'on';
            removeBtn.Enable = 'on';
            logToLog('Multi-folder mode enabled.');
        else
            subfolderTable.Enable = 'off';
            addBtn.Enable = 'off';
            removeBtn.Enable = 'off';
            logToLog('Multi-folder mode disabled.');
        end
    end

    function addRow()
        currentData = subfolderTable.Data;
        newRow = {'', ''};
        subfolderTable.Data = [currentData; newRow];
    end

    function removeRow()
        idx = subfolderTable.Selection;
        if isempty(idx)
            logToLog('⚠️ No row selected for deletion.');
            return;
        end
        data = subfolderTable.Data;
        data(idx(1),:) = [];
        subfolderTable.Data = data;
    end

    function closeFigure(src)
        saveLastSession();
        delete(src);
    end

    function BrowseandSaveConfig()
        %Look for where to save the current config.
        [file, path] = uiputfile('*.mat','Select Configuration File',localBaseField.Value);
        if isequal(file,0), return; end

        cfg = collectConfig();

        try
            save([path,'\',file], '-struct', 'cfg');
            uialert(fig, ['Configuration saved to ', path], 'Success');
        catch ME
            uialert(fig, ['Error saving: ', ME.message], 'Error');
        end

    end

    function BrowseandLoadConfig()
        %Look for where to save the current config.
        [file, path] = uigetfile('*.mat','Select Configuration File',localBaseField.Value);
        if isequal(file,0), return; end

        filepath=[path,'\',file];

        if ~isfile(filepath)
            uialert(fig, ['File not found: ', filepath], 'Error');
            return;
        end
        try
            cfg = load(filepath);
            applyConfig(cfg);
            uialert(fig, ['Configuration loaded from ', filepath], 'Success');
        catch ME
            uialert(fig, ['Error loading: ', ME.message], 'Error');
        end

    end

    function cfg = collectConfig()
        % --- Cluster Settings ---
        cfg.Hostname = hostnameField.Value;
        cfg.Username = usernameField.Value;

        %Do not save te password for safety purposes Ignore at your own
        %risk.
        %cfg.Password = passwordField.Value;

        % --- File Management ---
        cfg.remoteBaseField = remoteBaseField.Value;
        cfg.localBaseField = localBaseField.Value;
        cfg.FileToFetchField = FileToFetchField.Value;
        cfg.NameAppendToggle = NameAppendToggle.Value;
        cfg.multiToggle = multiToggle.Value;
        cfg.subfolderTableData = subfolderTable.Data;
        cfg.ToggleUpdate=ToggleUpdate.Value;

    end

    function applyConfig(cfg)
        % Cluster Settings
        if isfield(cfg,'Hostname'), hostnameField.Value = cfg.Hostname; end
        if isfield(cfg,'Username'), usernameField.Value = cfg.Username; end
        if isfield(cfg,'Password'), passwordField.Value = cfg.Password; end

        % File Management
        if isfield(cfg,'remoteBaseField'), remoteBaseField.Value = cfg.remoteBaseField; end
        if isfield(cfg,'localBaseField'), localBaseField.Value = cfg.localBaseField; end
        if isfield(cfg,'FileToFetchField'), FileToFetchField.Value = cfg.FileToFetchField; end
        if isfield(cfg,'NameAppendToggle'), NameAppendToggle.Value = cfg.NameAppendToggle; end
        if isfield(cfg,'multiToggle')
            multiToggle.Value = cfg.multiToggle;
            if cfg.multiToggle
                subfolderTable.Enable = 'on';
            elseif ~cfg.multiToggle
                subfolderTable.Enable = 'off';
            end
        end

        % Multi-Folders
        if isfield(cfg,'subfolderTableData'), subfolderTable.Data = cfg.subfolderTableData; end
        if isfield(cfg,'ToggleUpdate'), ToggleUpdate.Value = cfg.ToggleUpdate; end

    end

    function saveLastSession()
        try
            cfg = collectConfig();                 % full current UI state
            runningFile = mfilename('fullpath');   % folder of current script
            [folder, ~, ~] = fileparts(runningFile);
            lastCfgFile = fullfile(folder, 'last_config_sync.mat');
            save(lastCfgFile, '-struct', 'cfg');
        catch ME
            warning('Could not save last session config: %s', ME.message);
        end
    end

end
