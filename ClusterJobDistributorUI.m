
function ClusterJobDistributorUI
import matlab.ui.control.*
import matlab.ui.container.*

addpath('.\ssh2_v2_m1_r7\')
addpath('.\C_J_D_functions\')


%% --- Main Figure ---
screenSize = get(0, 'ScreenSize');
fig = uifigure('Name', 'Cluster Job Distributor', ...
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


%% ------------------ JOB CONFIGURATION TAB ------------------
tab2 = uitab(tg, 'Title', 'Jobs Configuration');
jobLayout = uigridlayout(tab2, [10, 4]);  % 4 columns
jobLayout.ColumnWidth = {'fit','1x','fit','fit'};
jobLayout.RowHeight = {22, 22, 35, 22, 22, 22, 22, 22, 30, 40};
jobLayout.ColumnSpacing = 8;
jobLayout.RowSpacing = 5;

% --- Row 1: Save Config ---
lbl = uilabel(jobLayout,'Text','Save Config:');
lbl.Layout.Row = 1; lbl.Layout.Column = 1;

saveConfigField = uieditfield(jobLayout,'text','Value',fullfile(pwd,'config.mat'));
saveConfigField.Layout.Row = 1; saveConfigField.Layout.Column = 2;

browseSaveFolderBtn = uibutton(jobLayout,'Text','Browse','ButtonPushedFcn',@(btn,event) browseSaveFolder());
browseSaveFolderBtn.Layout.Row = 1; browseSaveFolderBtn.Layout.Column = 3;

saveConfigBtn = uibutton(jobLayout,'Text','Save','ButtonPushedFcn',@(btn,event) saveConfig());
saveConfigBtn.Layout.Row = 1; saveConfigBtn.Layout.Column = 4;

% --- Row 2: Load Config ---
lbl = uilabel(jobLayout,'Text','Load Config:');
lbl.Layout.Row = 2; lbl.Layout.Column = 1;

loadConfigField = uieditfield(jobLayout,'text','Value',fullfile(pwd,'config.mat'));
loadConfigField.Layout.Row = 2; loadConfigField.Layout.Column = 2;


browseLoadFolderBtn = uibutton(jobLayout,'Text','Browse','ButtonPushedFcn',@(btn,event) browseLoadFile());
browseLoadFolderBtn.Layout.Row = 2; browseLoadFolderBtn.Layout.Column = 3;

loadConfigBtn = uibutton(jobLayout,'Text','Load','ButtonPushedFcn',@(btn,event) loadConfig());
loadConfigBtn.Layout.Row = 2; loadConfigBtn.Layout.Column = 4;

% Row 3: checkboxes
checkLayout = uigridlayout(jobLayout, [1, 5]);
checkLayout.Layout.Row = 3; checkLayout.Layout.Column = [1 4];
checkLayout.ColumnWidth = {'1x','1x','1x','1x','1x'};
ignoreState = uicheckbox(checkLayout, 'Text', 'Ignore State', 'ValueChangedFcn', @(src,event) toggleUseMixed());
useMixed = uicheckbox(checkLayout, 'Text', 'Use Mixed');
fillNodes = uicheckbox(checkLayout, 'Text', 'Fill Nodes');
randomDistrib = uicheckbox(checkLayout, 'Text', 'Random Distrib');
biggerFirst = uicheckbox(checkLayout, 'Text', 'Bigger First');

% Numeric fields
lbl = uilabel(jobLayout, 'Text', 'Prefered CPUs:'); lbl.Layout.Row = 4; lbl.Layout.Column = 1;
prefCPU = uieditfield(jobLayout, 'numeric', 'Value', 4,'Tooltip','Prefered number of CPUs assigned to each job. Final number may be larger when jobs are constrained by memory.'); prefCPU.Layout.Row = 4; prefCPU.Layout.Column = 2;
lbl = uilabel(jobLayout, 'Text', 'Min. CPUs:'); lbl.Layout.Row = 5; lbl.Layout.Column = 1;
minCPU = uieditfield(jobLayout, 'numeric', 'Value', 4,'Tooltip','Minimum number of CPUs acceptable to be assigned to a job.'); minCPU.Layout.Row = 5; minCPU.Layout.Column = 2;
lbl = uilabel(jobLayout, 'Text', 'Minimum Memory:'); lbl.Layout.Row = 6; lbl.Layout.Column = 1;
minMemTot = uieditfield(jobLayout, 'numeric', 'Value', 40000,'Tooltip','Minimum total memory (in MB) allocated for a particular job.'); minMemTot.Layout.Row = 6; minMemTot.Layout.Column = 2;
lbl = uilabel(jobLayout, 'Text', 'Delete Queues:'); lbl.Layout.Row= 7; lbl.Layout.Column = 1;
delQueues = uieditfield(jobLayout, 'text','Tooltip','Comma-separated list of queues to remove from the sweep'); delQueues.Layout.Row = 7; delQueues.Layout.Column = 2;
lbl = uilabel(jobLayout, 'Text', 'Delete Nodes:'); lbl.Layout.Row = 8; lbl.Layout.Column = 1;
delNodes = uieditfield(jobLayout, 'text','Tooltip','Comma-separated list of nodes to remove from the sweep'); delNodes.Layout.Row = 8; delNodes.Layout.Column = 2;

% Buttons row
buttonLayout = uigridlayout(jobLayout, [1,4]);
buttonLayout.Layout.Row = 9; buttonLayout.Layout.Column = [1 4];
buttonLayout.ColumnWidth = {'1x','1x','1x','1x'}; buttonLayout.RowHeight = {30}; buttonLayout.Padding = [0 0 0 0];
ClusterStateBtn = uibutton(buttonLayout, 'Text', 'Cluster state',...
    'ButtonPushedFcn', @(~,~)ClusterStateButtonPushed());
listQueuesBtn = uibutton(buttonLayout, 'Text', 'List Queues',...
    'ButtonPushedFcn', @(~,~)ListQueuesButtonPushed());
listNodesBtn = uibutton(buttonLayout, 'Text', 'List Nodes',...
    'ButtonPushedFcn', @(~,~)ListNodesButtonPushed());
enumerateBtn = uibutton(buttonLayout, 'Text', 'Enumerate Possible Jobs',...
    'ButtonPushedFcn', @(~,~)EnumeratePossibleJobsButtonPushed());


% Add new row before the jobLog for the clustercommand
clusterCmdLabel = uilabel(jobLayout, 'Text', {'Cluster','Command:'}, 'FontWeight', 'bold');
clusterCmdLabel.Layout.Row = 10;   
clusterCmdLabel.Layout.Column = 1;

clusterCmdArea = uitextarea(jobLayout);
clusterCmdArea.Layout.Row = 10;
clusterCmdArea.Layout.Column = [2 4];
clusterCmdArea.Value = {'comsol batch -np 4 -inputfile model.mph -outputfile Solved -batchlog Record.log'};


%% ------------------ Parameter Sweep Tab ------------------
tab3 = uitab(tg, 'Title', 'Parameter Sweep');
sweepLayout = uigridlayout(tab3, [1, 2]);
sweepLayout.ColumnWidth = {'2x', '1x'}; sweepLayout.RowHeight = {'1x'};
sweepTable = uitable(sweepLayout, 'ColumnName', {'Variable Name', 'Values (MATLAB Expression)'}, ...
    'ColumnEditable', [true true], 'Data', {'H_electr_nm','10.^(0:0.15:4)'; 'Ek_electron_MeV','linspace(0.01,2.2,30)'});
sweepTable.Layout.Row = 1; sweepTable.Layout.Column = 1;
controlLayout = uigridlayout(sweepLayout, [5,1]); controlLayout.Layout.Row = 1; controlLayout.Layout.Column = 2;
controlLayout.RowHeight = {22,22,22,22,'1x'};
addRowBtn = uibutton(controlLayout, 'Text', '+ Add Variable', 'ButtonPushedFcn', @(btn,event) addSweepRow()); addRowBtn.Layout.Row = 1;
removeRowBtn = uibutton(controlLayout, 'Text', '- Remove Selected', 'ButtonPushedFcn', @(btn,event) removeSweepRow()); removeRowBtn.Layout.Row = 2;
allCombCheck = uicheckbox(controlLayout, 'Text', 'All combinations', 'Value', true); allCombCheck.Layout.Row = 3;
testJobCountBtn = uibutton(controlLayout, 'Text', 'Test Job Count',...
    'ButtonPushedFcn', @(btn,event) testJobCountButtonPush()); testJobCountBtn.Layout.Row = 4;
dummy = uilabel(controlLayout, 'Text', ''); dummy.Layout.Row = 5;

%% ------------------ File Management Tab ------------------

tab4 = uitab(tg, 'Title', 'File Management');
fileLayout = uigridlayout(tab4, [6,3]);
fileLayout.RowHeight = {22,22,22,22,22,22};
fileLayout.ColumnWidth = {'fit','1x','fit'};

% --- Row 1: Model file selection ---
lbl = uilabel(fileLayout, 'Text','Model File(s):');
lbl.Layout.Row = 1; lbl.Layout.Column = 1;

modelFileField = uieditfield(fileLayout,'text');
modelFileField.Layout.Row = 1; modelFileField.Layout.Column = 2;

browseModelBtn = uibutton(fileLayout,'Text','Browse...', ...
    'ButtonPushedFcn',@(btn,event) browseFile());
browseModelBtn.Layout.Row = 1; browseModelBtn.Layout.Column = 3;

% --- Row 2: Local path ---
lbl = uilabel(fileLayout,'Text','Local Path:');
lbl.Layout.Row = 2; lbl.Layout.Column = 1;

localPathField = uieditfield(fileLayout,'text');
localPathField.Layout.Row = 2; localPathField.Layout.Column = 2;

% --- Row 3: Remote path and model(s) upload---
lbl = uilabel(fileLayout,'Text','Remote Path:');
lbl.Layout.Row = 3; lbl.Layout.Column = 1;

remotePathField = uieditfield(fileLayout,'text');
remotePathField.Layout.Row = 3; remotePathField.Layout.Column = 2;

uploadBtn = uibutton(fileLayout,'Text','Upload Model', ...
    'ButtonPushedFcn',@(btn,event)UploadModelButtonPush());
uploadBtn.Layout.Row = 3; uploadBtn.Layout.Column = 3;

% --- Row 4: Starting folder number ---
lbl = uilabel(fileLayout,'Text','Starting Folder #:');
lbl.Layout.Row = 4; lbl.Layout.Column = 1;

startFolderField = uieditfield(fileLayout,'numeric', ...
    'Value', 1, ...
    'Limits', [1 Inf], ...
    'Tooltip', 'Index of the first folder to create for the sweep');
startFolderField.Layout.Row = 4;
startFolderField.Layout.Column = 2;

% --- Row 5: parameter file name ---
lbl = uilabel(fileLayout,'Text','Parameter file name:');
lbl.Layout.Row = 5; lbl.Layout.Column = 1;

ParameterFileField = uieditfield(fileLayout,'text', ...
    'Value', 'param.txt', ...
    'Tooltip', 'Name of the file that holds the values of the parameters for each particular run');
ParameterFileField.Layout.Row = 5;
ParameterFileField.Layout.Column = 2;

% --- Row 6: script file name ---
lbl = uilabel(fileLayout,'Text','Script file name');
lbl.Layout.Row = 6; lbl.Layout.Column = 1;

ScriptFileField = uieditfield(fileLayout,'text', ...
    'Value', 'jobscript.sh', ...
    'Tooltip', 'Name of the script with the slurm commands');
ScriptFileField.Layout.Row = 6;
ScriptFileField.Layout.Column = 2;


%% ------------------ Execution Tab ------------------
tab5 = uitab(tg, 'Title', 'Execution');

execLayout = uigridlayout(tab5,[6,1]); 
execLayout.RowHeight = {'fit','fit','fit',2,'fit','fit'}; 
execLayout.ColumnWidth = {'1x'};
execLayout.RowSpacing = 8;

% --- Section title ---
batchTitle = uilabel(execLayout, ...
    'Text','Job Creation Section', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'HorizontalAlignment','left');
batchTitle.Layout.Row = 1;

% --- Auto-save controls ---
autoSaveLayout = uigridlayout(execLayout,[1,2]);
autoSaveLayout.ColumnWidth = {'fit','1x'};
autoSaveLayout.RowHeight = {'1x'};
autoSaveLayout.Padding = [0 0 0 0];
autoSaveLayout.Layout.Row = 2;
autoSaveLayout.ColumnSpacing = 10;

autoSaveCheck = uicheckbox(autoSaveLayout, ...
    'Text','Automatically save configuration file to simulation file folder', ...
    'Value',true, ...
    'Tooltip','If checked, automatically save configuration to the simulation folder.', ...
    'ValueChangedFcn',@(src,event) toggleAutoSave());
autoSaveCheck.Layout.Column = 1;

autoSaveName = uieditfield(autoSaveLayout,'text', ...
    'Value','auto_config.mat', ...
    'Tooltip','Name of the automatically saved configuration file');
autoSaveName.Layout.Column = 2;

% --- Run full pipeline button ---
runPipelineBtn = uibutton(execLayout,'Text','Run Full Pipeline', ...
    'Tooltip','Connect to cluster and generate one folder per parameter combination. Specify job characteristics per folder according to cluster specification.', ...
    'ButtonPushedFcn',@(btn,event) onRun());
runPipelineBtn.Layout.Row = 3;

% --- Separator ---
sepLabel = uilabel(execLayout, ...
    'Text','', ...
    'BackgroundColor',[0.7 0.7 0.7]); 
sepLabel.Layout.Row = 4;

% --- Section title ---
batchTitle = uilabel(execLayout, ...
    'Text','Job Launching Section', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'HorizontalAlignment','left');
batchTitle.Layout.Row = 5;

% --- Sub-layout for checkboxes and text field ---
batchLayout = uigridlayout(execLayout,[1,3]);
batchLayout.ColumnWidth = {'fit','1x','fit'};
batchLayout.RowHeight = {'1x'};
batchLayout.Padding = [0 0 0 0];
batchLayout.Layout.Row = 6;
batchLayout.ColumnSpacing = 10;

batchAllCheck = uicheckbox(batchLayout, ...
    'Text','All', ...
    'Tooltip','Select this to batch all jobs in the remote folder');
batchAllCheck.Layout.Column = 1;

customFoldersField = uieditfield(batchLayout, 'text', ...
    'Placeholder','e.g. 1-150 or 1,5,9,10', ...
    'Tooltip','Specify folder names to batch using comma separated lists to specify individual elements, and dashes to indicate ranges.');
customFoldersField.Layout.Column = 2;

% disable text field when "All" is checked
batchAllCheck.ValueChangedFcn = @(chk,~) set(customFoldersField, 'Enable', ~chk.Value);

% --- Batch buttons ---
BatchAllBtn = uibutton(batchLayout,'Text','Batch Specified Jobs', ...
    'Tooltip','Batch jobs in Remote Path as specified. WARNING: This may create a lot of running jobs in the cluster, make sure everything is under control before launching.', ...
    'ButtonPushedFcn',@(btn,event) confirmBatch(btn));
BatchAllBtn.Layout.Column = 3;


%% ------------ Load last session if it exists -----------------------
runningFile = mfilename('fullpath');
[folder, ~, ~] = fileparts(runningFile);

lastCfgFile = fullfile(folder, 'last_config_distributor.mat');

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

    function logToLog_and_clear(msg)
        t = datestr(now,'[HH:MM:SS]');
        sharedLog.Value = {t,msg};
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

    function [ssh2_conn,S] = getClusterState(ssh2_conn, headerFlag)

        %ssh2_conn = ssh2_config(host, user, password);

        %Contents: Partition, Nodes, CPUS (A/I/O/T), Memory, Free Memory,
        %State
        if headerFlag
            str_command='sinfo -a -S %P,hostname -o "|%13P|%13n|%13C|%13m|%13e|%8T|"';
        else
            str_command='sinfo -h -a -S %P,hostname -o "|%13P|%13n|%13C|%13m|%13e|%8T|"';
        end

        [ssh2_conn,S] = ssh2_command(ssh2_conn, str_command);
        ssh2_close(ssh2_conn);

    end

    function S_idle = filterActiveNodes(S, headerFlag)

        if headerFlag
            i0 = 2;
        else
            i0 = 1;
        end

        ind_keep = true(1, length(S));
        for i = i0:length(S)
            ind_keep(i) = contains(S{i}, 'idle') || contains(S{i}, 'mixed') || contains(S{i}, 'alloc');
        end

        S_idle = S(logical(ind_keep));
    end

    function [S_filtered,lookout_queues] = filterRequiredNodes(S)

        del_nodes = strtrim(strsplit(delNodes.Value, ','));
        del_nodes(cellfun('isempty', del_nodes)) = [];  % remove empty entries

        del_queues = strtrim(strsplit(delQueues.Value, ','));
        del_queues(cellfun('isempty', del_queues)) = [];

        lookout_queues = {};

        %First, filter specific nodes
        if ~isempty(del_nodes)
            nodeList = cell(size(S));
            for i = 1:length(S)
                parts = strsplit(S{i}, '|');
                nodeList{i} = strtrim(parts{3}); % node name is the 3rd column in your format
            end

            for k = 1:length(del_nodes)
                ind_keep = ~strcmp(nodeList,del_nodes{k});
                % Determine the queue associated with this node to remove
                if any(~ind_keep)
                    ln_rem=find(~ind_keep);
                    for i=1:length(ln_rem)
                        % Determine the queue associated with this node
                        tmp=strtrim(strsplit(S{ln_rem},'|'));
                        lookout_queues=[lookout_queues;tmp{2}];
                    end
                end
                S=S(ind_keep);
                nodeList=nodeList(ind_keep);
            end
            lookout_queues = unique(lookout_queues);
        end

        %del_queues is a cell array containing the name of the queues to
        %delete.
        if ~isempty(del_queues)
            for k=1:length(del_queues)
                ind_keep = ~contains(S,del_queues{k});
                S=S(ind_keep);
            end
        end

        S_filtered = S;

    end

    function nodeList = ExtractNodeList(S)
        % Extracts node names from sinfo output lines
        nodeList = cell(size(S));
        for i = 1:length(S)
            parts = strsplit(S{i}, '|');
            nodeList{i} = strtrim(parts{3}); % node name is the 3rd column in your format
        end
    end

    function QueueList = ExtractQueueList(S)
        % Extracts node names from sinfo output lines
        QueueList = cell(size(S));
        for i = 1:length(S)
            parts = strsplit(S{i}, '|');
            QueueList{i} = strtrim(parts{2}); % node name is the 3rd column in your format
        end
        %Keep only the unique different values
        QueueList=unique(QueueList);
    end

    function ListNodesButtonPushed()
        % --- Parameters for SSH connection ---
        host = hostnameField.Value;
        user = usernameField.Value;
        pass = passwordField.Value;

        % --- Basic validation ---
        if isempty(host) || isempty(user) || isempty(pass)
            logToLog('[Error] Please fill in hostname, username, and password before testing.');
            return;
        end

        headerFlag = true;                % Show header in sinfo output

        try
            % --- Get full cluster state ---
            ssh2_conn=EstablishBasicConnection();
            [~, S] = getClusterState(ssh2_conn, headerFlag);

            % --- Filter only active nodes ---
            S_active = filterActiveNodes(S, headerFlag);

            % --- Extract node names ---
            nodeList = ExtractNodeList(S_active);

            % --- Build log string ---
            logStr = sprintf('Active nodes:\n%s\n', repmat('-',1,30));
            for i = 1:length(nodeList)
                logStr = sprintf('%s%s\n', logStr, nodeList{i});
            end
            logStr = sprintf('%s%s\n', logStr, repmat('-',1,30));

            % --- Append to jobLog ---
            %currentLog = jobLog.Value;          % Get current text
            %jobLog.Value = [currentLog; logStr]; % Append new log
            logToLog(logStr)
        catch ME
            % Append error to jobLog
            %currentLog = jobLog.Value;
            %jobLog.Value = [currentLog; {sprintf('Failed to retrieve cluster nodes: %s', ME.message)}];
            logToLog(sprintf('Failed to retrieve cluster nodes: %s', ME.message))
        end
    end

    function ListQueuesButtonPushed()
        
        headerFlag = true;                % Show header in sinfo output

        try
            % --- Get full cluster state ---
            ssh2_conn=EstablishBasicConnection();
            [~, S] = getClusterState(ssh2_conn, headerFlag);

            % --- Filter only active nodes ---
            S_active = filterActiveNodes(S, headerFlag);

            % --- Extract node names ---
            QueueList = ExtractQueueList(S_active);

            % --- Build log string ---
            logStr = sprintf('Active Queues:\n%s\n', repmat('-',1,30));
            for i = 1:length(QueueList)
                logStr = sprintf('%s%s\n', logStr, QueueList{i});
            end
            logStr = sprintf('%s%s\n', logStr, repmat('-',1,30));

            % --- Append to jobLog ---
            %currentLog = jobLog.Value;          % Get current text
            %jobLog.Value = [currentLog; logStr]; % Append new log
            logToLog(logStr)
        catch ME
            % Append error to jobLog
            logToLog(sprintf('Failed to retrieve cluster queues: %s', ME.message))
            %currentLog = jobLog.Value;
            %jobLog.Value = [currentLog; {sprintf('Failed to retrieve cluster queues: %s', ME.message)}];
        end
    end

    function [S_valid,lookout_queues]=getFilteredClusterState(headerFlag,verboseFlag)
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %
        % Right now i'm here. I have tested the ssh connections, and the
        % ability to extract the cluster state. I have provided separated
        % functionality to list all the available queues, and all the available
        % nodes. These lists can be used to specify the nodes and queues to
        % remove from the list. This serves to not flood the whole cluster.
        %
        % Next, I will work on using these base functions to determine the list
        % of possible jobs that work according to the specifications. For this
        % I first get the filtered, nodelist, together with the lookout_queues.
        % I should be able to recycle most of the logic used in the previous
        % version to handle this.
        %
        %
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % --- Parameters for SSH connection ---

        %headerFlag = true;                % Show header in sinfo output

        try
            % --- Get full cluster state ---
            ssh2_conn=EstablishBasicConnection();
            [~, S] = getClusterState(ssh2_conn, headerFlag);

            % --- Filter only active nodes ---
            S_active = filterActiveNodes(S, headerFlag);

            if headerFlag
                [S_valid,lookout_queues] = filterRequiredNodes(S_active(2:end));
                S_valid=[S_active(1);S_valid];
            else
                [S_valid,lookout_queues] = filterRequiredNodes(S_active);
            end
            %-leak content for debugging
            %S_valid
            %lookout_queues

            if verboseFlag
                % --- Build log string ---
                logStr = sprintf('Cluster state (filtered):\n%s\n', repmat('-',1,30));
                for i = 1:length(S_valid)
                    logStr = sprintf('%s%s\n', logStr, S_valid{i});
                end
                logStr = sprintf('%s%s\n', logStr, repmat('-',1,30));

                % --- Append to jobLog ---
                logToLog(logStr)

                % currentLog = jobLog.Value;          % Get current text
                % jobLog.Value = [currentLog; logStr]; % Append new log
            end

        catch ME
            % Append error to jobLog
            %currentLog = jobLog.Value;
            logToLog(sprintf('Failed to retrieve cluster state: %s', ME.message))
            %jobLog.Value = [currentLog; {sprintf('Failed to retrieve cluster state: %s', ME.message)}];
        end

    end

    function P_jobs=EnumeratePossibleJobs(S,lookout_queues)

        P_jobs=[];
        %I change the order, before it was
        %-cpus - memory - node, and now it is:
        %- queue -node -cpus -memory

        if ~ignoreState.Value
            %Available cores:
            Cellf={};
            Cellm={};
            for i=1:length(S)
                info=split(S{i},'|')';
                tmp=cellfun(@(s) erase(s,' '),info(2:5),'UniformOutput',false);
                if contains(info{7},'idle')
                    Cellf=[Cellf;tmp];
                elseif contains(info{7},'mixed')
                    Cellm=[Cellm;tmp];
                end
            end

            P_jobs=Possible_jobs_mem_lims(Cellf,prefCPU.Value,minCPU.Value,...
                minMemTot.Value,ignoreState.Value,fillNodes.Value);
            P_jobs_m=Possible_jobs_mem_lims(Cellm,prefCPU.Value,minCPU.Value,...
                minMemTot.Value,ignoreState.Value,fillNodes.Value);

            if useMixed.Value
                P_jobs=[P_jobs;P_jobs_m];
            end

        elseif ignoreState.Value
            Cellf={};
            for i=1:length(S)
                info=split(S{i},'|')';
                tmp=cellfun(@(s) erase(s,' '),info(2:5),'UniformOutput',false);
                if contains(info{7},'idle')||contains(info{7},'mixed')||contains(info{7},'alloc')
                    Cellf=[Cellf;tmp];
                end
            end

            P_jobs=Possible_jobs_mem_lims(Cellf,prefCPU.Value,minCPU.Value,...
                minMemTot.Value,ignoreState.Value,fillNodes.Value);

        end

        %Add the node control column
        node_control=cell(size(P_jobs,1),1);
        for i=1:size(P_jobs,1)
            node_control{i}=any(strcmp(P_jobs(i,1),lookout_queues));
        end

        %Get the memory or cpu bound message to the end
        P_jobs=[P_jobs(:,1:end-1),node_control,P_jobs(:,end)];

        if ~randomDistrib.Value
            if biggerFirst.Value
                ord='descend';
            elseif ~biggerFirst.Value
                ord='ascend';
            end
            %Sort jobs according to number of assigned cores
            tmp=zeros(size(P_jobs(:,1)));
            for i=1:length(tmp)
                tmp(i)=sscanf(P_jobs{i,2},'%d');
            end
            [~,ind]=sort(tmp,ord);

        elseif randomDistrib.Value
            ind=randperm(size(P_jobs,1));
        end

        P_jobs=P_jobs(ind,:);

    end

    function ClusterStateButtonPushed()
        %This button just calls the function that returns the available
        %cluster nodes
        [~,~]=getFilteredClusterState(true,true);

    end

    function EnumeratePossibleJobsButtonPushed()

        [S_valid,lookout_queues]=getFilteredClusterState(false,false);

        P_jobs=EnumeratePossibleJobs(S_valid,lookout_queues);

        try
            % --- Build log string ---
            logStr = sprintf('%s\n',repmat('-',1,120));
            logStr = sprintf('%s Available jobs (filtered): %d \n %s\n',logStr,size(P_jobs,1),repmat('-',1,120));
            logStr = sprintf('%s Queue, NumCpus, MempCPU, Node, Node_lookout, Limitation\n %s\n',logStr,repmat('-',1,120));
            for i = 1:size(P_jobs,1)
                logStr = sprintf('%s|%15s|%15s|%15s|%15s|%15d|%15s|\n', logStr, P_jobs{i,:});
            end
            logStr = sprintf('%s%s\n', logStr, repmat('-',1,120));

            % --- Clear jobLog and display list---
            %currentLog = jobLog.Value;          % Get current text
            %jobLog.Value = [currentLog; logStr]; % Append new log
            %logToLog(logStr)
            logToLog_and_clear(logStr)
            %jobLog.Value = logStr; % Substitute by new message new log

        catch ME
            % Append error to jobLog
            %currentLog = jobLog.Value;
            logToLog(sprintf('Failed to generate possible jobs according to specifications: %s', ME.message))
            %jobLog.Value = [currentLog; {sprintf('Failed to generate possible jobs according to specifications: %s', ME.message)}];
        end

    end

    function [Candidates_sweep,Padded_sweep]=getJobParams()
        try
            % Extract data from the sweepTable
            data = sweepTable.Data;
            varNames = data(:,1);
            varExprs = data(:,2);

            % Evaluate each MATLAB expression safely
            Candidates_sweep = {};
            Candidates_value = {};
            for i = 1:length(varNames)
                name = strtrim(varNames{i});
                expr = strtrim(varExprs{i});
                if isempty(name) || isempty(expr)
                    continue; % skip empty rows
                end
                Candidates_sweep{end+1} = name;

                try
                    val = eval(expr); % evaluate numeric expression
                    if isnumeric(val) || islogical(val)
                        Candidates_value{end+1} = num2cell(val(:)); % store as cell array
                    else
                        error('Expression must return a numeric array');
                    end
                catch ME
                    uialert(fig, sprintf('Error evaluating expression for "%s": %s', name, ME.message), 'Evaluation Error');
                    return;
                end
            end

            % Call your existing sweep function
            All_comb = allCombCheck.Value;
            %Candidates_sweep
            Padded_sweep = ParamSweepGen_2(Candidates_sweep, Candidates_value, All_comb);

            % Display number of combinations
            logToLog(sprintf('Generated %d parameter combinations with %d variables.\n', ...
                size(Padded_sweep,1), size(Padded_sweep,2)));

        catch ME
            uialert(fig, sprintf('Error during sweep generation: %s', ME.message), 'Error');
        end

    end

    function testJobCountButtonPush()
        [~,~]=getJobParams();
    end

    function UploadModelToRemotePath()
        % --- Login ----
        ssh2_conn=EstablishBasicConnection();

        % --- File details ---
        model=modelFileField.Value;
        LocalPath=localPathField.Value;
        RemotePath=remotePathField.Value;

        % --- Basic validation ---
        log_file_flag=isempty(model) || isempty(LocalPath) || isempty(RemotePath);
        if log_file_flag
            logToLog('[Error] Please fill in Simulation file, local and remote paths for model upload.');
            return;
        end

        %Copy files specified in Model File field. It may be more than one
        %file:
        model = strtrim(strsplit(model, ','));

        %Check if model files actually exist and is a file (not folder)
        for i=1:length(model)
            if exist([LocalPath,model{i}],"file")~=2
                logToLog('[Error] Specified simulation files do not exist, or the local path is incorrect.');
                return;
            end
        end

        logToLog(sprintf('[Uploading] Computation files to %s...', RemotePath));
        ssh2_conn = sftp_put(ssh2_conn, model, RemotePath, LocalPath, model);

        % --- Close connection cleanly ---
        ssh2_close(ssh2_conn);
        logToLog('[Success] Files correctly uploaded.');

    end

    function UploadModelButtonPush()
        UploadModelToRemotePath()
    end

    function Run_Full_pipeline()
        %Steps:
        %1) Connect to the cluster and determine the number of jobs
        %available according to User specifications
        %2) Calculate the combinations of parameter runs. (Display a
        %warning if the number of combinations is larger than available
        %jobs)
        %2b) Upload the simulation files
        %3) Start Locally writing the parameter files and scripts
        %corresponding to each job
        %4) Compress all these files and upload them to the remote path.
        %5) Decompress on the remote cluster, create folders for each run,
        %and distribute parameter and script files to each folder
        %6) Copy simulation files to each simulation folder

        %1) Get cluster state and possible Jobs according to user
        %specifications
        [S_valid,lookout_queues]=getFilteredClusterState(false,false);
        P_jobs=EnumeratePossibleJobs(S_valid,lookout_queues);

        logToLog(sprintf('%d Jobs according to user specifications',size(P_jobs,1)));

        %2) Get the run parameters:
        [Candidates_sweep,Run_params]=getJobParams();
        logToLog(sprintf('%d Parameter combinations',size(Run_params,1)));

        %Test if number of simulations is larger than available job configurations
        N_oc=ceil(size(Run_params,1)./size(P_jobs,1));
        %If so, pad the list of possible jobs with itself so that it loops back
        if N_oc>=1
            logToLog('[Warning] More Jobs than available, your simulations will queue.');
            P_jobs=repmat(P_jobs,[ceil(N_oc),1]);
        end
        %This allows to run the index over the list of parameter values.

        %2b) Upload simulation file(s) to cluster
        UploadModelToRemotePath()
        logToLog('Uploaded simulation file.');

        %3) Write all scripts and parameter files for the simulations:
        %load in basis for script file:
        fid = fopen('./base_slurm_jobscript.sh','r');
        j = 1;
        tline = fgetl(fid);
        A{j} = tline;
        while ischar(tline)
            j = j+1;
            tline = fgetl(fid);
            A{j} = tline;
        end
        fclose(fid);

        % Now, instead of parallelizing the upload process, lets use BASH to
        % handle the redistribution process. To do so, I will generate locally all
        % the parameter and scripts, and then tar them and upload them to the
        % cluster all at once. This should be much much faster than sending them
        % over one by one.

        %I label each file by the destination folder in which I want them.

        %Create the list of job ids and detination folders to run them.
        job_number_init=1; job_number=job_number_init+(0:size(Run_params,1));
        folder_number_init=startFolderField.Value; folder_number=folder_number_init+(0:size(Run_params,1));

        %Create local folder to generate all the files:
        tmp_local_path='tmp_scripts_and_params';
        mkdir(['./',tmp_local_path,'/'])

        %Aux strings to build filenames during loop:
        js_parts=split(ScriptFileField.Value,'.');
        param_parts=split(ParameterFileField.Value,'.');

        %Create waitbar
        f=waitbar(0,'Creating folders for simulations');
        tavg=0;
        trest=Inf;

        %Loop through the different parameter combinations, modify the
        %slurm script for each job, and write the parameter file.
        for i=1:size(Run_params,1)
            waitbar(i/size(Run_params,1),f,{['Creating simulation files ',num2str(i),'/',num2str(size(Run_params,1))];['Estimated time remaining : ',num2str(trest),' s']});
            tic

            %The values of each parameter are in the same order as in
            %Candidates_sweep, because it is the order used by Param_sweep_Gen to
            %make the grid of values.
            jobscript_name=[js_parts{1},'_',num2str(folder_number(i)),'.',js_parts{2}];
            paramfile_name=[param_parts{1},'_',num2str(folder_number(i)),'.',param_parts{2}];

            %Save the run parameters
            fid_param=fopen(['./',tmp_local_path,'/',paramfile_name],'w');
            for k=1:length(Candidates_sweep)
                fprintf(fid_param,[Candidates_sweep{k},' %d\n'],Run_params{i,k});
            end
            fclose(fid_param);

            %Give job a name
            job_name=sprintf('N%d/%d',job_number(i),size(Run_params,1));

            % %Write the corresponding script
            writescript(job_name,P_jobs(i,:),A,clusterCmdArea.Value,...
                ['./',tmp_local_path,'/'],jobscript_name)

            t=toc;
            tavg=(t+(i-1)*tavg)/i;
            trest=tavg*(size(Run_params,1)-i);
        end

        waitbar(1,f,'Compressing and uploading');

        % 4) Compress the temporal folder with all the scripts and
        % instructions and upload it to the remote path
        tmp_local_path_tar=[tmp_local_path,'.tar'];
        tar(tmp_local_path_tar,tmp_local_path)

        %Move compressed files to cluster
        
        % --- Parameters for SSH connection ---
        model=modelFileField.Value;
        LocalPath=localPathField.Value;
        RemotePath=remotePathField.Value;

        % --- Basic validation ---
        log_file_flag= isempty(LocalPath) || isempty(RemotePath);

        if log_file_flag
            logToLog('[Error] Please fill in Simulation file, local and remote paths for model upload.');
            return;
        end

        %Establish connection to cluster
        ssh2_conn=EstablishBasicConnection();

        logToLog(sprintf('[Uploading] parameter and simulation files to %s', RemotePath));
        ssh2_conn = sftp_put(ssh2_conn, tmp_local_path_tar, RemotePath, pwd, tmp_local_path_tar);

        % 5) Unpack the compressed data, and then distribute the different
        % simulation files across the different folders

        %unpack and remove the compressed data
        ssh2_conn = ssh2_command(ssh2_conn,['cd ',RemotePath,'; tar -xf ',tmp_local_path_tar,'; rm ',tmp_local_path_tar],0);

        waitbar(1,f,'Sort and copying');
        %Distribute files across different folders, this is all done from a
        %single bash command. It goes as follows:
        % It goes to the folder where all the params and script files are.
        % It then gets all the different individual ids of the different files
        % It then uses these identifiers to create a folder and move all the files
        % to the corresponding folder, removing the identifyer.
        % Then it copies the associated simulation file to such folder.
        str_remote_files='';
        %In case of several files to copy to each folder, this will append the
        %instruction with each of the different files
        model = strtrim(strsplit(model, ','));
        for j=1:length(model)
            str_remote_files=[str_remote_files,'[ -f "$target/',model{j},'" ] || cp ../',model{j},' "$target/"; '];
        end

        Cluster_cmd_create_folds_move_params_and_sim_files=[...
            'cd ',RemotePath,tmp_local_path,'/ && ',...
            'for f in *_*.*; do ',...
            '[ -e "$f" ] || continue; ',...
            'id=$(echo "$f" | sed -E ''s/.*_([0-9]+)\..*/\1/''); ',...
            'base=$(echo "$f" | sed -E ''s/(.*)_[0-9]+(\..*)/\1\2/''); ',...
            'target=../$id; ',...
            'mkdir -p "$target"; ',...
            'mv "$f" "$target/$base"; ',...
            str_remote_files,...
            'done'];
        ssh2_conn = ssh2_command(ssh2_conn,Cluster_cmd_create_folds_move_params_and_sim_files,0);

        waitbar(1,f,'Cleanup');

        %Remove empty temporary folder
        ssh2_conn= ssh2_command(ssh2_conn,['cd ',RemotePath,'; ',...
            'rm -r ',tmp_local_path],0);
        %Delete current param and jobscript
        rmdir(tmp_local_path, 's')
        delete(['./',tmp_local_path_tar])

        % --- Close connection cleanly ---
        ssh2_close(ssh2_conn);
        logToLog('[Success] Files correctly uploaded and simulation folders created');
        close(f);
    end

    function writescript(job_name,Job_Params,Base_Script,Cluster_Command,writePath,jobscript_name)
        %In this function we use pre-defined keywords to adapt a general
        %slurm script to the particular jobs at hand. The different
        %Keywords are:
        % -%JOBNAME: Name that will appear in the slurm queue
        % -%QUEUE: Cluster queue
        % -%NODE: Node Name
        % -%NCPUs: Cpus assigned to job
        % -%MEMpCPU: Memory per cpu assigned to the job
        % -%RUN_COMMAND: Cluster command to run on each job.
        % -%ModelFile: Simulation file from the file management section.

        %Exclude the last line because it contains a number due to the read
        %in procedure.
        Mod_Script=Base_Script(1:end-1);

        %Check if the specify node instruction is operational. If not so,
        %comment the line in the script
        node_specify_flag=logical(Job_Params{5});
        if ~node_specify_flag
            ind=find(contains(Mod_Script,'#SBATCH --nodelist=%NODE'));
            Mod_Script{ind}='# SBATCH --nodelist=%NODE';
        end

        %Start defining the library of keywords, and their corresponding
        %value to introduce (in absence of the actual ,'%RUN_COMMAND'

        %Check that there is only one simulation file to assign
        %automatically:

        if length(strtrim(strsplit(modelFileField.Value, ',')))==1
            keyw0={'%JOBNAME','%QUEUE','%NODE','%NCPUs','%MEMpCPU','%ModelFile'};
            corr_vals0={job_name,Job_Params{1},Job_Params{4},Job_Params{2},Job_Params{3},modelFileField.Value};
        else
            logToLog('[Warning] More than one Model file specified, hard code the main file in the cluster command.');
            keyw0={'%JOBNAME','%QUEUE','%NODE','%NCPUs','%MEMpCPU'};
            corr_vals0={job_name,Job_Params{1},Job_Params{4},Job_Params{2},Job_Params{3}};
        end

        %We begin by getting the Cluster command and adapting it to each
        %Job:
        Mod_Cluster_Command=Cluster_Command;
        %Only one line: include it into a cell.
        if isstring(Mod_Cluster_Command) 
            Mod_Cluster_Command={Mod_Cluster_Command};
        end
        %Go through keywords to see if the cluster command contains any of
        %them, and substitute the corresponding values
        for i=1:length(keyw0)
            Mod_Cluster_Command=cellfun(@(s) strrep(s,keyw0{i},corr_vals0{i}),Mod_Cluster_Command,'UniformOutput',false);
        end

        %Now do the same to the base slurm script:
        for i=1:length(keyw0)
            Mod_Script=cellfun(@(s) strrep(s,keyw0{i},corr_vals0{i}),Mod_Script,'UniformOutput',false);
        end

        %Look for the final keyword in Mod_Script (%RUN_COMMAND), and
        %substitute it by the cell of the cluster command.
        ind = find(contains(Mod_Script, '%RUN_COMMAND'));


        %Append actual instruction to cell by substituting the ind line:
        Mod_Script=[Mod_Script(1:ind-1),Mod_Cluster_Command.',Mod_Script(ind+1:end),Base_Script(end)];

        %Save as script
        fid = fopen([writePath,jobscript_name], 'w');
        for i = 1:numel(Mod_Script)
            if Mod_Script{i+1} == -1
                fprintf(fid,'%s', Mod_Script{i});
                break
            else
                fprintf(fid,'%s\n', Mod_Script{i});
            end
        end

        fclose(fid);

    end
    
    function confirmBatch(btn)
        % Get handle to parent figure
        fig = ancestor(btn, 'figure');

        % Ask for confirmation
        choice = uiconfirm(fig, ...
            'Are you sure you want to batch all specified jobs? This will submit jobs to the cluster.', ...
            'Confirm Batch Launch', ...
            'Options', {'Yes', 'Cancel'}, ...
            'DefaultOption', 2, ...
            'Icon', 'warning');

        % Only proceed if user selects "Yes"
        if strcmp(choice, 'Yes')
            onBatchJobs();
        else
            logToLog('Batching cancelled by user.');
        end
    end

    function onBatchJobs()
        %This function takes the input parameters from the GUI and batches
        %the different jobs in the remote path folder.
        
        %First check if the all is enabled. 
        %If so, go to the cluster and get all the numeric folder list.
        if batchAllCheck.Value
            Dir_list_Rem_Path=QueryRemotePathSubFolders();
        else
            %If not, translate the instructions of the specific ranges into an array.
            StrListRem=customFoldersField.Value;
            %Validate, only numeric characters with commas and dashes are
            %allowed. 
            if isempty(regexp(StrListRem, '^[0-9,\-\s]+$', 'once'))
                logToLog('[error] Invalid syntax for the specified folder list: only digits, commas, dashes, and spaces are allowed. Example: "1-10, 15, 20-25".');
                return;
            end

            sections=strip(split(StrListRem,','),' ');
            %Remove empty entries
            empty_entries=cellfun(@(s) isempty(s),sections);

            sections=sections(~empty_entries);
            aux_sections=contains(sections,'-');
            
            Dir_list_Rem_Path=[];
            for i=1:length(sections)
                if aux_sections(i)==1
                    n1=str2double(extractBefore(sections{i},'-'));
                    n2=str2double(extractAfter(sections{i},'-'));
                    tmp=n1:n2;
                else
                    tmp=str2double(sections{i});
                end
                Dir_list_Rem_Path=[Dir_list_Rem_Path,tmp];
            end
            Dir_list_Rem_Path=sort(Dir_list_Rem_Path.');
        end
        
        %Now that I have the arrays of numbers I create a function that 
        % returns a string that I can run in bash to obtain
        %the same range of values:
        bashStr_array=BashStringRangeGenerator(Dir_list_Rem_Path);

        %I now call a function that injects this string into a bash script,
        %together with the name of the slurm script that have been
        %uploaded 
        name_tmp_script=rewrite_bulk_batch_script(bashStr_array);

        %Upload new batch script to the cluster remote path.
        % --- Parameters for SSH connection ---
        ssh2_conn=EstablishBasicConnection();
        LocalPath=[pwd,'\'];
        RemotePath=remotePathField.Value;

        % --- Basic validation ---
        log_file_flag=isempty(name_tmp_script) || isempty(LocalPath) || isempty(RemotePath);
        
        if log_file_flag
            logToLog('[Error] Please fill in Simulation file, local and remote paths for model upload.');
            return;
        end

        %Copy bulk batch script 
        %Check if model files actually exist and is a file (not folder)
        if exist([LocalPath,name_tmp_script],"file")~=2
            logToLog('[Error] Specified simulation files do not exist, or the local path is incorrect.');
            return;
        end

        logToLog(sprintf('[Uploading] Bulk batch script to %s...', RemotePath));
        ssh2_conn = sftp_put(ssh2_conn, name_tmp_script, RemotePath, LocalPath, name_tmp_script);
        
        % Remove local batch file:
        delete([LocalPath,name_tmp_script])
        logToLog('[Cleaning] Removing local copy of Bulk batch script.');
        
        %Log to RemotePath and change permissions of file so that it can be
        %executed. Grab answer. 
        logToLog('Launching bulk batching operation:')
        [ssh2_conn, aux_response] = ssh2_command(ssh2_conn, ['cd ',RemotePath,'; '...
            'chmod +x ',name_tmp_script,'; ',...
            './',name_tmp_script]);
        for i=1:length(aux_response)
            logToLog(aux_response{i})
        end
        
        % --- Close connection cleanly ---
        ssh2_close(ssh2_conn);
        logToLog('[Success] Files correctly uploaded, and desired bulk batch executed.');

    end

    function Dir_list_Rem_Path=QueryRemotePathSubFolders()
        %Establish connection to cluster
        ssh2_conn=EstablishBasicConnection();

        RemotePath=remotePathField.Value;       
        
        [ssh2_conn, Dir_list_Rem_Path] = ssh2_command(ssh2_conn, ['cd ',RemotePath,'; ls -d -- */']);
        ssh2_close(ssh2_conn);
        
        %Remove trailing bar that comes from the ls command. 
        Dir_list_Rem_Path = strip(Dir_list_Rem_Path,'/');

        %Remove folders with names that are not purely numeric. 
        isNumericName = cellfun(@(s) ~isempty(regexp(s,'^\s*\d+\s*$','once')), Dir_list_Rem_Path);
        if any(~isNumericName)
            logToLog('[Warning] Some folder in remote path doesn''t have numeric name. Ignoring it when bulk batching simulations')
        end

        % Filter valid ones
        Dir_list_Rem_Path = Dir_list_Rem_Path(isNumericName);

        % Convert to numeric array and sort
        Dir_list_Rem_Path = cellfun(@str2double, Dir_list_Rem_Path);
        Dir_list_Rem_Path = sort(Dir_list_Rem_Path);
    end

    function bashStr=BashStringRangeGenerator(Folder_number_array)
        %This function takes a sorted array of unique integers that correspond to
        %the folders with simulations to run and turns it into
        %bash-interpretable string that generates the same array.
        if isempty(Folder_number_array)
            bashStr = 'folders=()';
            return;
        end

        Folder_number_array = sort(unique(Folder_number_array(:)'));  % ensure sorted, row vector, unique entries
        ranges = {};  % cell array for range strings

        i = 1;
        while i <= numel(Folder_number_array)
            startVal = Folder_number_array(i);
            j = i;
            % find contiguous run
            while j < numel(Folder_number_array) && Folder_number_array(j+1) == Folder_number_array(j) + 1
                j = j + 1;
            end
            endVal = Folder_number_array(j);

            if endVal > startVal + 1
                % more than 2 numbers -> use bash {start..end}
                ranges{end+1} = sprintf('{%d..%d}', startVal, endVal);
            
            elseif endVal == startVal + 1
                % two consecutive numbers, shorter to just list them
                ranges{end+1} = sprintf('%d %d', startVal, endVal);
            else
                % single number
                ranges{end+1} = sprintf('%d', startVal);
            end
            i = j + 1;
        end

        % combine into bash array literal
        bashStr = sprintf('(%s)', strjoin(ranges, ' '));
    end
    
    function name_tmp_script=rewrite_bulk_batch_script(bashStr_array)
        % Read template
        template = fileread('base_bulk_batch_script.sh');

        % Replace placeholders
        template = strrep(template, '%FOLDER_LIST', bashStr_array);
        template = strrep(template, '%JOBSCRIPT_NAME', ScriptFileField.Value);

        % Write new script
        name_tmp_script='script_bulk_batch.sh';
        fid = fopen(name_tmp_script, 'w');
        fprintf(fid, '%s', template);
        fclose(fid);

    end

% -----------------------------GUI actions functions------------------------

    function toggleUseMixed()
        if ignoreState.Value
            useMixed.Value = true;
            useMixed.Enable = 'off';
        else
            useMixed.Enable = 'on';
        end
    end

    function addSweepRow()
        sweepTable.Data(end+1,:) = {'',''};
    end

    function removeSweepRow()
        idx = sweepTable.Selection;
        if ~isempty(idx)
            sweepTable.Data(idx(1),:) = [];
        end
    end

    function closeFigure(src)
        saveLastSession();
        delete(src);
    end

    function browseFile()
        [files, path] = uigetfile('*.*''Select one or more files', ...
            'MultiSelect', 'on');
        if isequal(files,0)
            % User cancelled
            return;
        elseif ischar(files)
            % Single file selected
            fileString = files;
        else
            % Multiple files selected -> filenames is a cell array
            fileString = strjoin(files, ', ');
        end

        modelFileField.Value = fileString;
        localPathField.Value = path;
    end

    function browseSavePath()
        [file, path] = uiputfile('*.mat','Select Configuration File');
        if isequal(file,0), return; end
        saveConfigField.Value = fullfile(path,file);
    end

    function browseLoadPath()
        [file, path] = uigetfile('*.mat','Select Configuration File');
        if isequal(file,0), return; end
        loadConfigField.Value = fullfile(path,file);
    end

    function cfg = collectConfig()
        % --- Cluster Settings ---
        cfg.Hostname = hostnameField.Value;
        cfg.Username = usernameField.Value;

        %Do not save te password for safety purposes
        %cfg.Password = passwordField.Value;

        % --- Job Configuration ---
        cfg.IgnoreState = ignoreState.Value;
        cfg.UseMixed = useMixed.Value;
        cfg.FillNodes = fillNodes.Value;
        cfg.RandomDistrib = randomDistrib.Value;
        cfg.BiggerFirst = biggerFirst.Value;
        cfg.PrefCPU = prefCPU.Value;
        cfg.MinCPU = minCPU.Value;
        cfg.MinMemTot = minMemTot.Value;
        cfg.DelQueues = delQueues.Value;
        cfg.DelNodes = delNodes.Value;
        cfg.clusterCmdArea=clusterCmdArea.Value;

        % --- Parameter Sweep ---
        cfg.SweepTableData = sweepTable.Data;       % cell array with variable names & values
        cfg.AllComb = allCombCheck.Value;          % whether "All_comb" is checked

        % --- File Management ---
        cfg.ModelFile = modelFileField.Value;
        cfg.LocalPath = localPathField.Value;
        cfg.RemotePath = remotePathField.Value;
        cfg.startFolderField=startFolderField.Value;
        cfg.ParameterFileField=ParameterFileField.Value;
        cfg.ScriptFileField=ScriptFileField.Value;

    end

    function saveConfig()
        cfg = collectConfig();
        filepath = saveConfigField.Value;
        try
            save(filepath, '-struct', 'cfg');
            uialert(fig, ['Configuration saved to ', filepath], 'Success');
        catch ME
            uialert(fig, ['Error saving: ', ME.message], 'Error');
        end
    end

    function loadConfig()
        filepath = loadConfigField.Value;
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

    function browseSaveFolder()
        folder = uigetdir(pwd,'Select Folder to Save Config');
        if isequal(folder,0), return; end
        saveConfigField.Value = fullfile(folder, 'config.mat'); % default filename
    end

    function browseLoadFile()
        [file, path] = uigetfile('*.*', 'Select Configuration File to Load'); % allow any filename
        if isequal(file,0), return; end
        loadConfigField.Value = fullfile(path, file);
    end

    function applyConfig(cfg)
        % Cluster Settings
        if isfield(cfg,'Hostname'), hostnameField.Value = cfg.Hostname; end
        if isfield(cfg,'Username'), usernameField.Value = cfg.Username; end
        if isfield(cfg,'Password'), passwordField.Value = cfg.Password; end

        % Job Configuration
        if isfield(cfg,'IgnoreState'), ignoreState.Value = cfg.IgnoreState; end
        if isfield(cfg,'UseMixed'), useMixed.Value = cfg.UseMixed; end
        if isfield(cfg,'FillNodes'), fillNodes.Value = cfg.FillNodes; end
        if isfield(cfg,'RandomDistrib'), randomDistrib.Value = cfg.RandomDistrib; end
        if isfield(cfg,'BiggerFirst'), biggerFirst.Value = cfg.BiggerFirst; end
        if isfield(cfg,'PrefCPU'), prefCPU.Value = cfg.PrefCPU; end
        if isfield(cfg,'MinCPU'), minCPU.Value = cfg.MinCPU; end
        if isfield(cfg,'MinMemTot'), minMemTot.Value = cfg.MinMemTot; end
        if isfield(cfg,'DelQueues'), delQueues.Value = cfg.DelQueues; end
        if isfield(cfg,'DelNodes'), delNodes.Value = cfg.DelNodes; end
        if isfield(cfg,'clusterCmdArea'), clusterCmdArea.Value = cfg.clusterCmdArea; end


        % Parameter Sweep
        if isfield(cfg,'SweepTableData'), sweepTable.Data = cfg.SweepTableData; end
        if isfield(cfg,'AllComb'), allCombCheck.Value = cfg.AllComb; end

        % File Management
        if isfield(cfg,'ModelFile'), modelFileField.Value = cfg.ModelFile; end
        if isfield(cfg,'LocalPath'), localPathField.Value = cfg.LocalPath; end
        if isfield(cfg,'RemotePath'), remotePathField.Value = cfg.RemotePath; end
        if isfield(cfg,'startFolderField'), startFolderField.Value = cfg.startFolderField; end
        if isfield(cfg,'ScriptFileField'), ScriptFileField.Value = cfg.ScriptFileField; end
        if isfield(cfg,'ParameterFileField'), ParameterFileField.Value = cfg.ParameterFileField; end

    end

    function toggleAutoSave()
        if autoSaveCheck.Value
            autoSaveName.Enable = 'on';
        else
            autoSaveName.Enable = 'off';
        end
    end

    function onRun()
        % Use Local Path field from File Management tab
        folder = localPathField.Value;
        if isempty(folder)
            folder = pwd;
            sharedLog.Value = [sharedLog.Value; {'[Info] Local Path empty — using current folder.'}];
        end

        if autoSaveCheck.Value
            filename = autoSaveName.Value;
            filepath = fullfile(folder, filename);
            cfg = collectConfig();
            try
                save(filepath,'-struct','cfg');
                sharedLog.Value = [sharedLog.Value; {['[AutoSave] Configuration saved to ' filepath]}];
            catch ME
                sharedLog.Value = [sharedLog.Value; {['[Error] Auto-save failed: ' ME.message]}];
            end
        else
            sharedLog.Value = [sharedLog.Value; {'[Info] Auto-save disabled — running pipeline without saving config.'}];
        end

        saveLastSession();

        Run_Full_pipeline();

    end

    function saveLastSession()
        try
            cfg = collectConfig();                 % full current UI state
            runningFile = mfilename('fullpath');   % folder of current script
            [folder, ~, ~] = fileparts(runningFile);
            lastCfgFile = fullfile(folder, 'last_config_distributor.mat');
            save(lastCfgFile, '-struct', 'cfg');
        catch ME
            warning('Could not save last session config: %s', ME.message);
        end
    end

end
