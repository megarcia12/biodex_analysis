% M3 Lab
% biodexAnalysis.m
% Created 26 October 2022
% Mario Garcia | nfq3bd@virginia.edu
close all; clear; clc;

%% File Location
PathName = uigetdir('.txt','Select the file you wish to analyize'); % only looks for .txt files
% Get a list of all files in the folder with desired pattern
filePattern = fullfile(PathName, '**/*.txt');
Files = dir(filePattern);
Files = {Files.name}';

%% File splitting
fn=regexp(Files,'\w*(?=.txt)','match');
fname = [fn{:,:}]';
cng = regexp(fname,'_','split');
change = [cng{:,:}]';
num_subs_times_parameters = length(change);
change = reshape(change,[num_subs_times_parameters./length(Files),length(Files)]);

%% Assigns Information based on regular trial or iterative change
[m,~] = size(change);
if m == 4
    subject = change(1,:);
    joint = change(3,: );
    direc = change(4,:);
else
    iteration = change(1,:);
    subject = change(2,:);
    joint = change(4,: );
    direc = change(5,:);
end

for n=1:length(Files)
    trial{1,n} = [joint{1,n},'_',direc{1,n}];
end

%% Get the data from the files
for nfiles = 1:length(Files)
    csub = subject{nfiles};
    cjoint = joint{nfiles};
    cdirection = direc{nfiles};
    sNum = str2num(csub(end-1:end));

    [deMVC.(csub).(trial{nfiles}).rmvc, deMVC.(csub).(trial{nfiles}).fmvc, ...
        deMVC.(csub).(trial{nfiles}).pmvc, deMVC.(csub).(trial{nfiles}).amvc, ...
        deMVC.(csub).(trial{nfiles}).mmvc, deMVC.(csub).(trial{nfiles}).smvc, ...
        deMVC.(csub).(trial{nfiles}).cmvc, metadata.(csub).(trial{nfiles}).ind_metadata] = importBiodex(fullfile(PathName, Files{nfiles}));

    rMVC.(csub).(trial{nfiles}) = deMVC.(csub).(trial{nfiles}).rmvc; % Raw
    fMVC.(csub).(trial{nfiles}) = deMVC.(csub).(trial{nfiles}).fmvc; % Filtered
    mMVC.(csub).(trial{nfiles}) = deMVC.(csub).(trial{nfiles}).pmvc; % Max Torque
    pMVC.(csub).(trial{nfiles}) = deMVC.(csub).(trial{nfiles}).cmvc; % Max of Each Rep
    aMVC.(csub).(trial{nfiles}) = deMVC.(csub).(trial{nfiles}).amvc; % Average
    amMVC.(csub).(trial{nfiles}) = deMVC.(csub).(trial{nfiles}).mmvc; % Midpoint Average
    afMVC.(csub).(trial{nfiles}) = deMVC.(csub).(trial{nfiles}).smvc; % Forward Average

    %% Checks each trial against metadata to make sure there are no errors in naming
    csub = convertCharsToStrings(csub);
    cjoint = convertCharsToStrings(cjoint);
    cdirection = convertCharsToStrings(cdirection);

    j = metadata.(subject{1,nfiles}).(trial{1,nfiles}).ind_metadata.subject;
    k =  metadata.(subject{1,nfiles}).(trial{1,nfiles}).ind_metadata.joint;
    l =  metadata.(subject{1,nfiles}).(trial{1,nfiles}).ind_metadata.match;

    if ~strcmpi(csub, j) || ~strcmpi(cjoint, k) || ~strcmpi(cdirection, l)
        fprintf('Mismatch in metadata for %s_%s_%s\n', csub, cjoint, cdirection);
        fprintf('Expected metadata: %s_%s_%s\n', j, k, l);
        fprintf('The file is located in %s\n', PathName);
        if m ~= 4
            citer = convertCharsToStrings(iteration{1, nfiles});
            fprintf('Using iteration code %s\n', citer);
        end
        break;
    end
end

%% Var clearing
clear cdirection cjoint ctrial j k l nfiles Loc
clear num_sub_times_parameters subject testingparameter trial
clear direc Files joint num_subs_times_parameters s filePattern


%% Save check
fprintf('Would you like to save this data?\n')
promt = input('Save -> [Y|N]\n','s');
exp = promt;
if strcmpi(exp,'y')
    %% Folder Check/Creation
    csub = sprintf(csub);
    dataFolder = uigetdir('D:\', 'Select Location you would like to save this data');
    location = fullfile(dataFolder, 'Biodex_Processed_Data');

    if ~exist(location, 'dir')
        mkdir(dataFolder,'Biodex_Processed_Data')
    end
    folders = {'rMVC', 'fMVC', 'mMVC', 'pMVC', 'aMVC', 'amMVC', 'afMVC'};

    for folderIdx = 1:length(folders)
        currFolder = fullfile(dataFolder, 'Biodex_Processed_Data', folders{folderIdx});
        if ~exist(currFolder, 'dir')
            mkdir(currFolder);
        end
        currFile = fullfile(currFolder, csub);
        save(currFile, folders{folderIdx});
    end

    clear n change fn fname cng m iteration exp promt csub PathName
else
    clear n change fn fname cng m iteration location exp promt csub PathName
end