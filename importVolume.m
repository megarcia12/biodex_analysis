% M3 Lab
% importVolume.m
% Created Feb 2023
% Mario Garcia | nfq3bd@virginia.edu

%% Import Muscle Designations
mDPath = "C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Collected Data\Biodex\Muscle Volumes\Muscle Volume Designation.txt";
mDO = delimitedTextImportOptions("NumVariables", 7);
mDO.DataLines = [2, Inf];
mDO.Delimiter = "\t";
mDO.VariableNames = ["Joint", "Movement", "Muscle","A1_Contributions","A2_Contributions","A3_Contributions","A4_Contributions"];
mDO.VariableTypes = ["string", "string", "string","double","double","double","double"];
mDO = setvaropts(mDO, "Muscle", "WhitespaceRule", "preserve");
mDO = setvaropts(mDO, ["Joint", "Movement", "Muscle"], "EmptyFieldRule", "auto");
% Import the data
muscDesig = readtable(mDPath, mDO);
muscDesig(:,8:20) = []; % Removes additional columns that contain no data points
muscDesig.A4_Contributions(isnan(muscDesig.A4_Contributions)) = 0; % Replaces NaN values with 0
% Variable Clearing
clear mDPath mDO

%% Muscle Volume Path
pathName = 'C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Collected Data\Biodex\Muscle Volumes'; % Select folder containing data
Files = dir(fullfile(pathName,'*.txt')); % Finds text files
Files = {Files.name}'; % List of files to import
% File Names
fn=regexp(Files,'\w*(?=.txt)','match');
fnames = [fn{:,:}]'; % Removes .txt to get subject IDs
fnames(end) = [];

%% Import Volume Data
opts = delimitedTextImportOptions("NumVariables", 9);
% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = "\t";
% Specify column names and types
opts.VariableNames = ["GroupStructureName", "Type", "Asymmetry", "SBScore", "VolumeScore", "FatInfiltration", "RawVolumeml", "Heightm", "Weightkg"];
opts.VariableTypes = ["string", "string", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Specify variable properties
opts = setvaropts(opts, "GroupStructureName", "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["GroupStructureName", "Type"], "EmptyFieldRule", "auto");

%% Import the data
for i = 1:size(fnames)
    tempName = horzcat(pathName,'\',(Files{i})); % Creates a file path as a temp name that changes through each iteration
    raw = readtable(tempName, opts); % Creates a raw table using the temp name and txt file
    vol.(fnames{i}).RawData = raw; % Saves raw values
    rVals = table2cell(raw(:,1)); % Saves muscle and bone names
    rVals = [rVals{:}]'; % Converts the names to character array
    raw(:,end) = []; raw(:,end) = []; % Removes height and mass
    rawVol = table2array(raw(:,end)); % Saves volumes from raw data
    rawFI = table2array(raw(:,6)); % Saves fat infiltration from raw data

    %% Muscle Volume Locations
    % Left Side
    mLocL = []; % Initiates empty array
    for j = 1:size(muscDesig,1) % Goes through entire list of muscles with associated joints and movements
        strTFnd = {'L.';(muscDesig{j,3})}; % Creates the string for search
        k = find(contains(rVals,strTFnd{1},IgnoreCase=true)&contains(rVals,strTFnd{2},IgnoreCase=true),1); % Finds index for specific names on the left side
        if isempty(k) % If it can not find the muscle on specified side
            k = 0; % Creates an index of 0
        end
        mLocL = [mLocL;k]; % Builds array
    end

    % Right Side
    mLocR = []; % Initiates empty array
    for j = 1:size(muscDesig,1)
        strTFnd = {'R.';(muscDesig{j,3})}; % Creates the string for search
        k = find(contains(rVals,strTFnd{1},IgnoreCase=true)&contains(rVals,strTFnd{2},IgnoreCase=true)); % Finds index for specific names on the right side
        if isempty(k) % If it can not find the muscle on specified side
            k = 0; % Creates an index of 0
        end
        mLocR = [mLocR;k]; % Builds array
    end

    %% Indexing Changes
    jInd = []; mInd = []; % Initiates empty arrays 
    for j = 1:size(muscDesig,1)-1 % Iterates through almost full list - does not look at last value to avoid fenceposting issue
        if strcmpi(muscDesig{j,1},muscDesig{j+1,1}) % Compares the current joint with the next joint
        else % If they are the same nothing happens, if different
            jInd = [jInd;j]; % Saves the index of change from one joint to the other
        end
    end

    for j = 1:size(muscDesig,1)-1 % Same as above to avoid fenceposting
        if strcmpi(muscDesig{j,2},muscDesig{j+1,2}) % Compares the current movement with the next one
        else % If they are the same nothing happens, if different
            mInd = [mInd;j]; % Saves the index of change from one movement to the other
        end
    end

    total_VolumeL = []; total_ContractileL = []; % Creates empty array for values, used to get rid of previous trials
    % Left Side
    for k = 1:size(muscDesig,1) % Iterates through hip trials based on indexing preformed above
        valL = mLocL(k); % Assigns value from muscle location
        if valL == 0 % If muscle was not found in search
            total_VolumeL = [total_VolumeL;0]; % Assigns volume of 0
            total_ContractileL = [total_ContractileL;0]; % Assigns a corrected volume of 0
        else
            total_VolumeL = [total_VolumeL;rawVol(valL)]; % Finds volume
            total_ContractileL = [total_ContractileL;rawVol(valL) - (rawVol(valL)/100)*rawFI(valL)]; % Finds volume without fat infiltration
        end
    end

    % Right Side
    total_VolumeR = []; total_ContractileR = []; % Creates empty array for values, used to get rid of previous trials
    for k = 1:size(muscDesig,1) % Iterates through hip trials based on indexing preformed above
        valR = mLocR(k); % Assigns value from muscle location
        if valR == 0 % If muscle was not found in search
            total_VolumeR = [total_VolumeR;0]; % Assigns volume of 0
            total_ContractileR = [total_ContractileR;0]; % Assigns a corrected volume of 0
        else
            total_VolumeR = [total_VolumeR;rawVol(valR)]; % Finds volume
            total_ContractileR = [total_ContractileR;rawVol(valR) - (rawVol(valR)/100)*rawFI(valR)]; % Finds volume without fat infiltration
        end
    end

    %% Ankle Volumes
    % Ankle Dorsiflexion
    musNames = {}; 
    A1 = []; A2 = []; A3 = []; A4 = []; % Initializes contribution based off angle
    for k = 1:mInd(1) % Finds muscles for hip flexion based off indexing
        musNames = [musNames;(muscDesig{k,3})];
        musNames = cellstr(musNames);
        A1 = [A1;(muscDesig{k,4})]; A2 = [A2;(muscDesig{k,5})];
        A3 = [A3;(muscDesig{k,6})]; A4 = [A4;(muscDesig{k,7})];
    end

    tblL = table(musNames,total_VolumeL(1:mInd(1)),total_ContractileL(1:mInd(1))); % Creates left side table
    tblL.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"]; % Assigns names
    tblR = table(musNames,total_VolumeR(1:mInd(1)),total_ContractileR(1:mInd(1))); % Creates right side table
    tblR.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"]; % Assigns names
    vol.(fnames{i}).(muscDesig{1,1}).L.(muscDesig{1,2}).Volume = sum(total_VolumeL(1:mInd(1))); % Calculates total volume for ankle dorsiflexion on the left side
    vol.(fnames{i}).(muscDesig{1,1}).L.(muscDesig{1,2}).Volume_Contract = sum(total_ContractileL(1:mInd(1))); % Calculates contractile volume for ankle dorsiflexion on the left side
    vol.(fnames{i}).(muscDesig{1,1}).R.(muscDesig{1,2}).Volume = sum(total_VolumeR(1:mInd(1))); % Calculates total volume for ankle dorsiflexion on the right side
    vol.(fnames{i}).(muscDesig{1,1}).R.(muscDesig{1,2}).Volume_Contract = sum(total_ContractileR(1:mInd(1))); % Calculates contractile volume for ankle dorsiflexion on the right side
    % Left Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{1,1}).L.(muscDesig{1,2}).ABV(1,1) = sum(A1.*total_VolumeL(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).L.(muscDesig{1,2}).ABV(2,1) = sum(A2.*total_VolumeL(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).L.(muscDesig{1,2}).ABV(3,1) = sum(A3.*total_VolumeL(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).L.(muscDesig{1,2}).ABV(4,1) = sum(A4.*total_VolumeL(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).L.(muscDesig{1,2}).ABCV(1,1) = sum(A1.*total_ContractileL(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).L.(muscDesig{1,2}).ABCV(2,1) = sum(A2.*total_ContractileL(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).L.(muscDesig{1,2}).ABCV(3,1) = sum(A3.*total_ContractileL(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).L.(muscDesig{1,2}).ABCV(4,1) = sum(A4.*total_ContractileL(1:mInd(1)));
    % Right Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{1,1}).R.(muscDesig{1,2}).ABV(1,1) = sum(A1.*total_VolumeR(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).R.(muscDesig{1,2}).ABV(2,1) = sum(A2.*total_VolumeR(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).R.(muscDesig{1,2}).ABV(3,1) = sum(A3.*total_VolumeR(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).R.(muscDesig{1,2}).ABV(4,1) = sum(A4.*total_VolumeR(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).R.(muscDesig{1,2}).ABCV(1,1) = sum(A1.*total_ContractileR(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).R.(muscDesig{1,2}).ABCV(2,1) = sum(A2.*total_ContractileR(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).R.(muscDesig{1,2}).ABCV(3,1) = sum(A3.*total_ContractileR(1:mInd(1)));
    vol.(fnames{i}).(muscDesig{1,1}).R.(muscDesig{1,2}).ABCV(4,1) = sum(A4.*total_ContractileR(1:mInd(1)));
    % Muscle Volumes 
    vol.(fnames{i}).(muscDesig{1,1}).L.(muscDesig{1,2}).Muscles = tblL; % Saves left side table
    vol.(fnames{i}).(muscDesig{1,1}).R.(muscDesig{1,2}).Muscles = tblR; % Saves right side table

    % Ankle Plantar Flexion
    musNames = {};
    A1 = []; A2 = []; A3 = []; A4 = []; % Initializes contribution based off angle
    for k = mInd(1)+1:mInd(2) % Finds muscles for ankle plantar flexion based off indexing
        musNames = [musNames;(muscDesig{k,3})];
        musNames = cellstr(musNames);
        A1 = [A1;(muscDesig{k,4})]; A2 = [A2;(muscDesig{k,5})];
        A3 = [A3;(muscDesig{k,6})]; A4 = [A4;(muscDesig{k,7})];
    end % See ankle dorsiflexion for associated functionality

    tblL = table(musNames,total_VolumeL(mInd(1)+1:mInd(2)),total_ContractileL(mInd(1)+1:mInd(2)));
    tblL.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    tblR = table(musNames,total_VolumeR(mInd(1)+1:mInd(2)),total_ContractileR(mInd(1)+1:mInd(2)));
    tblR.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).L.(muscDesig{mInd(1)+1,2}).Volume = sum(total_VolumeL(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).L.(muscDesig{mInd(1)+1,2}).Volume_Contract = sum(total_ContractileL(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).R.(muscDesig{mInd(1)+1,2}).Volume = sum(total_VolumeR(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).R.(muscDesig{mInd(1)+1,2}).Volume_Contract = sum(total_ContractileR(mInd(1)+1:mInd(2)));
    % Left Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).L.(muscDesig{mInd(1)+1,2}).ABV(1,1) = sum(A1.*total_VolumeL(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).L.(muscDesig{mInd(1)+1,2}).ABV(2,1) = sum(A2.*total_VolumeL(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).L.(muscDesig{mInd(1)+1,2}).ABV(3,1) = sum(A3.*total_VolumeL(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).L.(muscDesig{mInd(1)+1,2}).ABV(4,1) = sum(A4.*total_VolumeL(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).L.(muscDesig{mInd(1)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileL(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).L.(muscDesig{mInd(1)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileL(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).L.(muscDesig{mInd(1)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileL(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).L.(muscDesig{mInd(1)+1,2}).ABCV(4,1) = sum(A4.*total_ContractileL(mInd(1)+1:mInd(2)));
    % Right Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).R.(muscDesig{mInd(1)+1,2}).ABV(1,1) = sum(A1.*total_VolumeR(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).R.(muscDesig{mInd(1)+1,2}).ABV(2,1) = sum(A2.*total_VolumeR(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).R.(muscDesig{mInd(1)+1,2}).ABV(3,1) = sum(A3.*total_VolumeR(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).R.(muscDesig{mInd(1)+1,2}).ABV(4,1) = sum(A4.*total_VolumeR(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).R.(muscDesig{mInd(1)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileR(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).R.(muscDesig{mInd(1)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileR(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).R.(muscDesig{mInd(1)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileR(mInd(1)+1:mInd(2)));
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).R.(muscDesig{mInd(1)+1,2}).ABCV(4,1) = sum(A4.*total_ContractileR(mInd(1)+1:mInd(2)));
    % Muscle Volumes
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).L.(muscDesig{mInd(1)+1,2}).Muscles = tblL;
    vol.(fnames{i}).(muscDesig{mInd(1)+1,1}).R.(muscDesig{mInd(1)+1,2}).Muscles = tblR;

    %Full Ankle Volume
    vol.(fnames{i}).(muscDesig{1,1}).TVol = sum(total_VolumeL)+sum(total_VolumeR); % Adds left and right side total volumes
    vol.(fnames{i}).(muscDesig{1,1}).ConVol = sum(total_ContractileL)+sum(total_ContractileR); % Adds left and right side total contractile volumes
    vol.(fnames{i}).(muscDesig{1,1}).L.TVol = sum(total_VolumeL(1:jInd(1))); % Sum of left total volume
    vol.(fnames{i}).(muscDesig{1,1}).L.ConVol = sum(total_ContractileL(1:jInd(1))); % Sum of left contractile volumes
    vol.(fnames{i}).(muscDesig{1,1}).R.TVol = sum(total_VolumeR(1:jInd(1))); % Sum of right total volume
    vol.(fnames{i}).(muscDesig{1,1}).R.ConVol = sum(total_ContractileR(1:jInd(1))); % Sum of right contractile volumes

    %% Hip Volumes
    % Hip Abductors
    musNames = {};
    A1 = []; A2 = []; A3 = []; % Initializes contribution based off angle
    for k = mInd(2)+1:mInd(3) % Finds muscles for hip abduction based off indexing
        musNames = [musNames;(muscDesig{k,3})];
        musNames = cellstr(musNames);
        A1 = [A1;(muscDesig{k,4})]; A2 = [A2;(muscDesig{k,5})];
        A3 = [A3;(muscDesig{k,6})];
    end % See hip flexors for associated functionality
    tblL = table(musNames,total_VolumeL(mInd(2)+1:mInd(3)),total_ContractileL(mInd(2)+1:mInd(3)));
    tblL.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    tblR = table(musNames,total_VolumeR(mInd(2)+1:mInd(3)),total_ContractileR(mInd(2)+1:mInd(3)));
    tblR.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).L.(muscDesig{mInd(2)+1,2}).Volume = sum(total_VolumeL(mInd(2)+1:mInd(3)));
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).L.(muscDesig{mInd(2)+1,2}).Volume_Contract = sum(total_ContractileL(mInd(2)+1:mInd(3)));
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).R.(muscDesig{mInd(2)+1,2}).Volume = sum(total_VolumeR(mInd(2)+1:mInd(3)));
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).R.(muscDesig{mInd(2)+1,2}).Volume_Contract = sum(total_ContractileR(mInd(2)+1:mInd(3)));
    % Left Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).L.(muscDesig{mInd(2)+1,2}).ABV(1,1) = sum(A1.*total_VolumeL(mInd(2)+1:mInd(3)));
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).L.(muscDesig{mInd(2)+1,2}).ABV(2,1) = sum(A2.*total_VolumeL(mInd(2)+1:mInd(3)));
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).L.(muscDesig{mInd(2)+1,2}).ABV(3,1) = sum(A3.*total_VolumeL(mInd(2)+1:mInd(3)));
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).L.(muscDesig{mInd(2)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileL(mInd(2)+1:mInd(3)));
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).L.(muscDesig{mInd(2)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileL(mInd(2)+1:mInd(3)));
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).L.(muscDesig{mInd(2)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileL(mInd(2)+1:mInd(3)));
    % Right Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).R.(muscDesig{mInd(2)+1,2}).ABV(1,1) = sum(A1.*total_VolumeR(mInd(2)+1:mInd(3)));
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).R.(muscDesig{mInd(2)+1,2}).ABV(2,1) = sum(A2.*total_VolumeR(mInd(2)+1:mInd(3)));
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).R.(muscDesig{mInd(2)+1,2}).ABV(3,1) = sum(A3.*total_VolumeR(mInd(2)+1:mInd(3)));
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).R.(muscDesig{mInd(2)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileR(mInd(2)+1:mInd(3)));
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).R.(muscDesig{mInd(2)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileR(mInd(2)+1:mInd(3)));
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).R.(muscDesig{mInd(2)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileR(mInd(2)+1:mInd(3)));
    % Muscle Volumes
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).L.(muscDesig{mInd(2)+1,2}).Muscles = tblL;
    vol.(fnames{i}).(muscDesig{mInd(2)+1,1}).R.(muscDesig{mInd(2)+1,2}).Muscles = tblR;

    % Hip Adductors
    musNames = {};
    A1 = []; A2 = []; A3 = []; % Initializes contribution based off angle
    for k = mInd(3)+1:mInd(4) % Finds muscles for hip adduction based off indexing
        musNames = [musNames;(muscDesig{k,3})];
        musNames = cellstr(musNames);
        A1 = [A1;(muscDesig{k,4})]; A2 = [A2;(muscDesig{k,5})];
        A3 = [A3;(muscDesig{k,6})];
    end % See hip flexors for associated functionality
    tblL = table(musNames,total_VolumeL(mInd(3)+1:mInd(4)),total_ContractileL(mInd(3)+1:mInd(4)));
    tblL.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    tblR = table(musNames,total_VolumeR(mInd(3)+1:mInd(4)),total_ContractileR(mInd(3)+1:mInd(4)));
    tblR.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).L.(muscDesig{mInd(3)+1,2}).Volume = sum(total_VolumeL(mInd(3)+1:mInd(4)));
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).L.(muscDesig{mInd(3)+1,2}).Volume_Contract = sum(total_ContractileL(mInd(3)+1:mInd(4)));
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).R.(muscDesig{mInd(3)+1,2}).Volume = sum(total_VolumeR(mInd(3)+1:mInd(4)));
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).R.(muscDesig{mInd(3)+1,2}).Volume_Contract = sum(total_ContractileR(mInd(3)+1:mInd(4)));
    % Left Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).L.(muscDesig{mInd(3)+1,2}).ABV(1,1) = sum(A1.*total_VolumeL(mInd(3)+1:mInd(4)));
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).L.(muscDesig{mInd(3)+1,2}).ABV(2,1) = sum(A2.*total_VolumeL(mInd(3)+1:mInd(4)));
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).L.(muscDesig{mInd(3)+1,2}).ABV(3,1) = sum(A3.*total_VolumeL(mInd(3)+1:mInd(4)));
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).L.(muscDesig{mInd(3)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileL(mInd(3)+1:mInd(4)));
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).L.(muscDesig{mInd(3)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileL(mInd(3)+1:mInd(4)));
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).L.(muscDesig{mInd(3)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileL(mInd(3)+1:mInd(4)));
    % Right Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).R.(muscDesig{mInd(3)+1,2}).ABV(1,1) = sum(A1.*total_VolumeR(mInd(3)+1:mInd(4)));
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).R.(muscDesig{mInd(3)+1,2}).ABV(2,1) = sum(A2.*total_VolumeR(mInd(3)+1:mInd(4)));
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).R.(muscDesig{mInd(3)+1,2}).ABV(3,1) = sum(A3.*total_VolumeR(mInd(3)+1:mInd(4)));
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).R.(muscDesig{mInd(3)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileR(mInd(3)+1:mInd(4)));
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).R.(muscDesig{mInd(3)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileR(mInd(3)+1:mInd(4)));
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).R.(muscDesig{mInd(3)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileR(mInd(3)+1:mInd(4)));
    % Muscle Volumes
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).L.(muscDesig{mInd(3)+1,2}).Muscles = tblL;
    vol.(fnames{i}).(muscDesig{mInd(3)+1,1}).R.(muscDesig{mInd(3)+1,2}).Muscles = tblR;

    % Hip Extensors
    musNames = {};
    A1 = []; A2 = []; A3 = []; % Initializes contribution based off angle
    for k = mInd(4)+1:mInd(5) % Finds muscles for hip extension based off indexing
        musNames = [musNames;(muscDesig{k,3})];
        musNames = cellstr(musNames);
        A1 = [A1;(muscDesig{k,4})]; A2 = [A2;(muscDesig{k,5})];
        A3 = [A3;(muscDesig{k,6})];
    end % See ankle dorsiflexion for associated functionality
    tblL = table(musNames,total_VolumeL(mInd(4)+1:mInd(5)),total_ContractileL(mInd(4)+1:mInd(5)));
    tblL.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    tblR = table(musNames,total_VolumeR(mInd(4)+1:mInd(5)),total_ContractileR(mInd(4)+1:mInd(5)));
    tblR.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).L.(muscDesig{mInd(4)+1,2}).Volume = sum(total_VolumeL(mInd(4)+1:mInd(5)));
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).L.(muscDesig{mInd(4)+1,2}).Volume_Contract = sum(total_ContractileL(mInd(4)+1:mInd(5)));
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).R.(muscDesig{mInd(4)+1,2}).Volume = sum(total_VolumeR(mInd(4)+1:mInd(5)));
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).R.(muscDesig{mInd(4)+1,2}).Volume_Contract = sum(total_ContractileR(mInd(4)+1:mInd(5)));
    % Left Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).L.(muscDesig{mInd(4)+1,2}).ABV(1,1) = sum(A1.*total_VolumeL(mInd(4)+1:mInd(5)));
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).L.(muscDesig{mInd(4)+1,2}).ABV(2,1) = sum(A2.*total_VolumeL(mInd(4)+1:mInd(5)));
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).L.(muscDesig{mInd(4)+1,2}).ABV(3,1) = sum(A3.*total_VolumeL(mInd(4)+1:mInd(5)));
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).L.(muscDesig{mInd(4)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileL(mInd(4)+1:mInd(5)));
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).L.(muscDesig{mInd(4)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileL(mInd(4)+1:mInd(5)));
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).L.(muscDesig{mInd(4)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileL(mInd(4)+1:mInd(5)));
    % Right Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).R.(muscDesig{mInd(4)+1,2}).ABV(1,1) = sum(A1.*total_VolumeR(mInd(4)+1:mInd(5)));
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).R.(muscDesig{mInd(4)+1,2}).ABV(2,1) = sum(A2.*total_VolumeR(mInd(4)+1:mInd(5)));
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).R.(muscDesig{mInd(4)+1,2}).ABV(3,1) = sum(A3.*total_VolumeR(mInd(4)+1:mInd(5)));
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).R.(muscDesig{mInd(4)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileR(mInd(4)+1:mInd(5)));
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).R.(muscDesig{mInd(4)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileR(mInd(4)+1:mInd(5)));
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).R.(muscDesig{mInd(4)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileR(mInd(4)+1:mInd(5)));
    % Muscle Volumes
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).L.(muscDesig{mInd(4)+1,2}).Muscles = tblL;
    vol.(fnames{i}).(muscDesig{mInd(4)+1,1}).R.(muscDesig{mInd(4)+1,2}).Muscles = tblR;

    % Hip Flexors
    musNames = {};
    A1 = []; A2 = []; A3 = []; % Initializes contribution based off angle
    for k = mInd(5)+1:mInd(6) % Finds muscles for hip flexion based off indexing
        musNames = [musNames;(muscDesig{k,3})];
        musNames = cellstr(musNames);
        A1 = [A1;(muscDesig{k,4})]; A2 = [A2;(muscDesig{k,5})];
        A3 = [A3;(muscDesig{k,6})];
    end % See ankle dorsiflexion for associated functionality
    tblL = table(musNames,total_VolumeL(mInd(5)+1:mInd(6)),total_ContractileL(mInd(5)+1:mInd(6)));
    tblL.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    tblR = table(musNames,total_VolumeR(mInd(5)+1:mInd(6)),total_ContractileR(mInd(5)+1:mInd(6)));
    tblR.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).L.(muscDesig{mInd(5)+1,2}).Volume = sum(total_VolumeL(mInd(5)+1:mInd(6)));
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).L.(muscDesig{mInd(5)+1,2}).Volume_Contract = sum(total_ContractileL(mInd(5)+1:mInd(6)));
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).R.(muscDesig{mInd(5)+1,2}).Volume = sum(total_VolumeR(mInd(5)+1:mInd(6)));
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).R.(muscDesig{mInd(5)+1,2}).Volume_Contract = sum(total_ContractileR(mInd(5)+1:mInd(6)));
    % Left Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).L.(muscDesig{mInd(5)+1,2}).ABV(1,1) = sum(A1.*total_VolumeL(mInd(5)+1:mInd(6)));
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).L.(muscDesig{mInd(5)+1,2}).ABV(2,1) = sum(A2.*total_VolumeL(mInd(5)+1:mInd(6)));
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).L.(muscDesig{mInd(5)+1,2}).ABV(3,1) = sum(A3.*total_VolumeL(mInd(5)+1:mInd(6)));
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).L.(muscDesig{mInd(5)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileL(mInd(5)+1:mInd(6)));
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).L.(muscDesig{mInd(5)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileL(mInd(5)+1:mInd(6)));
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).L.(muscDesig{mInd(5)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileL(mInd(5)+1:mInd(6)));
    % Right Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).R.(muscDesig{mInd(5)+1,2}).ABV(1,1) = sum(A1.*total_VolumeR(mInd(5)+1:mInd(6)));
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).R.(muscDesig{mInd(5)+1,2}).ABV(2,1) = sum(A2.*total_VolumeR(mInd(5)+1:mInd(6)));
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).R.(muscDesig{mInd(5)+1,2}).ABV(3,1) = sum(A3.*total_VolumeR(mInd(5)+1:mInd(6)));
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).R.(muscDesig{mInd(5)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileR(mInd(5)+1:mInd(6)));
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).R.(muscDesig{mInd(5)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileR(mInd(5)+1:mInd(6)));
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).R.(muscDesig{mInd(5)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileR(mInd(5)+1:mInd(6)));
    % Muscle Volumes
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).L.(muscDesig{mInd(5)+1,2}).Muscles = tblL;
    vol.(fnames{i}).(muscDesig{mInd(5)+1,1}).R.(muscDesig{mInd(5)+1,2}).Muscles = tblR;

    %Full Hip Volume
    vol.(fnames{i}).(muscDesig{jInd(1)+1,1}).TVol = sum(total_VolumeL(mInd(2)+1:mInd(6)))+sum(total_VolumeR(mInd(4)+1:mInd(6))); % Adds left and right side total volumes
    vol.(fnames{i}).(muscDesig{jInd(1)+1,1}).ConVol = sum(total_ContractileL(mInd(2)+1:mInd(6)))+sum(total_ContractileR(mInd(4)+1:mInd(6))); % Adds left and right side total contractile volumes
    vol.(fnames{i}).(muscDesig{jInd(1)+1,1}).L.TVol = sum(total_VolumeL(mInd(2)+1:mInd(6))); % Sum of left total volume
    vol.(fnames{i}).(muscDesig{jInd(1)+1,1}).L.ConVol = sum(total_ContractileL(mInd(2)+1:mInd(6))); % Sum of left contractile volumes
    vol.(fnames{i}).(muscDesig{jInd(1)+1,1}).R.TVol = sum(total_VolumeR(mInd(2)+1:mInd(6))); % Sum of right total volume
    vol.(fnames{i}).(muscDesig{jInd(1)+1,1}).R.ConVol = sum(total_ContractileR(mInd(2)+1:mInd(6))); % Sum of right contractile volumes

    %% Knee Volumes
    % Knee Extensors
    musNames = {};
    A1 = []; A2 = []; A3 = []; A4 = []; % Initializes contribution based off angle
    for k = mInd(6)+1:mInd(7) % Finds muscles for knee extension based off indexing
        musNames = [musNames;(muscDesig{k,3})];
        musNames = cellstr(musNames);
        A1 = [A1;(muscDesig{k,4})]; A2 = [A2;(muscDesig{k,5})];
        A3 = [A3;(muscDesig{k,6})]; A4 = [A4;(muscDesig{k,7})];
    end % See ankle dorsiflexion for associated functionality
    tblL = table(musNames,total_VolumeL(mInd(6)+1:mInd(7)),total_ContractileL(mInd(6)+1:mInd(7)));
    tblL.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    tblR = table(musNames,total_VolumeR(mInd(6)+1:mInd(7)),total_ContractileR(mInd(6)+1:mInd(7)));
    tblR.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).L.(muscDesig{mInd(6)+1,2}).Volume = sum(total_VolumeL(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).L.(muscDesig{mInd(6)+1,2}).Volume_Contract = sum(total_ContractileL(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).R.(muscDesig{mInd(6)+1,2}).Volume = sum(total_VolumeR(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).R.(muscDesig{mInd(6)+1,2}).Volume_Contract = sum(total_ContractileR(mInd(6)+1:mInd(7)));
    % Left Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).L.(muscDesig{mInd(6)+1,2}).ABV(1,1) = sum(A1.*total_VolumeL(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).L.(muscDesig{mInd(6)+1,2}).ABV(2,1) = sum(A2.*total_VolumeL(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).L.(muscDesig{mInd(6)+1,2}).ABV(3,1) = sum(A3.*total_VolumeL(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).L.(muscDesig{mInd(6)+1,2}).ABV(4,1) = sum(A4.*total_VolumeL(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).L.(muscDesig{mInd(6)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileL(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).L.(muscDesig{mInd(6)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileL(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).L.(muscDesig{mInd(6)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileL(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).L.(muscDesig{mInd(6)+1,2}).ABCV(4,1) = sum(A4.*total_ContractileL(mInd(6)+1:mInd(7)));
    % Right Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).R.(muscDesig{mInd(6)+1,2}).ABV(1,1) = sum(A1.*total_VolumeR(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).R.(muscDesig{mInd(6)+1,2}).ABV(2,1) = sum(A2.*total_VolumeR(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).R.(muscDesig{mInd(6)+1,2}).ABV(3,1) = sum(A3.*total_VolumeR(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).R.(muscDesig{mInd(6)+1,2}).ABV(4,1) = sum(A4.*total_VolumeR(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).R.(muscDesig{mInd(6)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileR(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).R.(muscDesig{mInd(6)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileR(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).R.(muscDesig{mInd(6)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileR(mInd(6)+1:mInd(7)));
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).R.(muscDesig{mInd(6)+1,2}).ABCV(4,1) = sum(A4.*total_ContractileR(mInd(6)+1:mInd(7)));
    % Muscle Volumes
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).L.(muscDesig{mInd(6)+1,2}).Muscles = tblL;
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).R.(muscDesig{mInd(6)+1,2}).Muscles = tblR;

    % Knee Flexors
    musNames = {};
    A1 = []; A2 = []; A3 = []; A4 = []; % Initializes contribution based off angle
    for k = mInd(7)+1:size(mLocL,1) % Finds muscles for knee flexion based off indexing
        musNames = [musNames;(muscDesig{k,3})];
        musNames = cellstr(musNames);
        A1 = [A1;(muscDesig{k,4})]; A2 = [A2;(muscDesig{k,5})];
        A3 = [A3;(muscDesig{k,6})]; A4 = [A4;(muscDesig{k,7})];
    end % See ankle dorsiflexion for associated functionality
    tblL = table(musNames,total_VolumeL(mInd(7)+1:size(mLocL,1)),total_ContractileL(mInd(7)+1:size(mLocL,1)));
    tblL.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    tblR = table(musNames,total_VolumeR(mInd(7)+1:size(mLocL,1)),total_ContractileR(mInd(7)+1:size(mLocL,1)));
    tblR.Properties.VariableNames = ["Muscle","Volume","Contractile Volume"];
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).L.(muscDesig{mInd(7)+1,2}).Volume = sum(total_VolumeL(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).L.(muscDesig{mInd(7)+1,2}).Volume_Contract = sum(total_ContractileL(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).R.(muscDesig{mInd(7)+1,2}).Volume = sum(total_VolumeR(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).R.(muscDesig{mInd(7)+1,2}).Volume_Contract = sum(total_ContractileR(mInd(7)+1:size(mLocL,1)));
    % Left Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).L.(muscDesig{mInd(7)+1,2}).ABV(1,1) = sum(A1.*total_VolumeL(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).L.(muscDesig{mInd(7)+1,2}).ABV(2,1) = sum(A2.*total_VolumeL(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).L.(muscDesig{mInd(7)+1,2}).ABV(3,1) = sum(A3.*total_VolumeL(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).L.(muscDesig{mInd(7)+1,2}).ABV(4,1) = sum(A4.*total_VolumeL(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).L.(muscDesig{mInd(7)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileL(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).L.(muscDesig{mInd(7)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileL(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).L.(muscDesig{mInd(7)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileL(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).L.(muscDesig{mInd(7)+1,2}).ABCV(4,1) = sum(A4.*total_ContractileL(mInd(7)+1:size(mLocL,1)));
    % Right Angle Based Volume Contribution
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).R.(muscDesig{mInd(7)+1,2}).ABV(1,1) = sum(A1.*total_VolumeR(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).R.(muscDesig{mInd(7)+1,2}).ABV(2,1) = sum(A2.*total_VolumeR(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).R.(muscDesig{mInd(7)+1,2}).ABV(3,1) = sum(A3.*total_VolumeR(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).R.(muscDesig{mInd(7)+1,2}).ABV(4,1) = sum(A4.*total_VolumeR(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).R.(muscDesig{mInd(7)+1,2}).ABCV(1,1) = sum(A1.*total_ContractileR(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).R.(muscDesig{mInd(7)+1,2}).ABCV(2,1) = sum(A2.*total_ContractileR(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).R.(muscDesig{mInd(7)+1,2}).ABCV(3,1) = sum(A3.*total_ContractileR(mInd(7)+1:size(mLocL,1)));
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).R.(muscDesig{mInd(7)+1,2}).ABCV(4,1) = sum(A4.*total_ContractileR(mInd(7)+1:size(mLocL,1)));
    % Muscle Volumes
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).L.(muscDesig{mInd(7)+1,2}).Muscles = tblL;
    vol.(fnames{i}).(muscDesig{mInd(7)+1,1}).R.(muscDesig{mInd(7)+1,2}).Muscles = tblR;

    %Full Knee Volume
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).TVol = sum(total_VolumeL(mInd(6)+1:size(mLocL,1)))+sum(total_VolumeR(mInd(6)+1:size(mLocL,1))); % Adds left and right side total volumes
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).ConVol = sum(total_ContractileL(mInd(6)+1:size(mLocL,1)))+sum(total_ContractileR(mInd(6)+1:size(mLocL,1))); % Adds left and right side total contractile volumes
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).L.TVol = sum(total_VolumeL(mInd(6))+1:size(mLocL,1)); % Sum of left total volume
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).L.ConVol = sum(total_ContractileL(mInd(6))+1:size(mLocL,1)); % Sum of left contractile volumes
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).R.TVol = sum(total_VolumeR(mInd(6))+1:size(mLocL,1)); % Sum of right total volume
    vol.(fnames{i}).(muscDesig{mInd(6)+1,1}).R.ConVol = sum(total_ContractileR(mInd(6))+1:size(mLocR,1)); % Sum of right contractile volumes
end

%% Variable Clearing
clear Corrected cTable Files fn fnames i Infiltration j k opts pathName raw rawFI rawVol total_ContractileL total_ContractileR mLocL mLocR
clear ROI tempName Volume t rVals mLoc muscDesig strTFnd musNames tblL tblR val jInd mInd valL valR total_VolumeL total_VolumeR A1 A2 A3 A4