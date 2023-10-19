% M3 Lab
% mvcComp.m
% Created 12 June 2023
% Mario Garcia | nfq3bd@virginia.edu

%% File Location
KeyPath=('C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Collected Data\Biodex\biodex_analysis'); % Input path were files are located
addpath(KeyPath); run('demographic.m');
anthro = rmfield(anthro, ["M06", "F05", "F07"]); % Subjects who do not have full data sets and need to be removed
anthro = rmfield(anthro,["F21", "F26", "M02", "M03"]); % Removes subjects who do not have volume data
pathName = 'C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Collected Data\Biodex\Biodex_Processed_Data\mMVC';
filePattern = fullfile(pathName, '*.mat');
matFiles = dir(filePattern); % Finds mat files that will be imported
bd = struct(); % Initialize the main structure
for i = 1:length(matFiles) % Determines how many files will be imported
    matdata = load(fullfile(pathName, matFiles(i).name)); % Loads mat files and saves them using sID
    tempName = matdata.mMVC; % Creates a temp name for saving
    x = fieldnames(tempName); % Finds the inner structure to reduce redundancy in naming
    bd.(x{1}) = tempName; % Creates structure
end

bd = rmfield(bd,["M06", "F05", "F07", "M13"]); % Removes subjects who do not have full data sets or do not fit within our inclusion criteria 
bd = rmfield(bd,["F21", "F26", "M02", "M03", "F14"]); % Removes subjects who do not have volume data
subID = fieldnames(bd); % Creates subject IDs to iterate over
momDir = fieldnames(bd.(subID{1}).(subID{1})); % Determines moment directions
joint = struct(); % Initialize the joint structure

for j = 1:numel(momDir)
    ang = fieldnames(bd.(subID{1}).(subID{1}).(momDir{j})); % Determines the angles for the moment directions
    for l = 1:numel(ang)
        joint.(momDir{j}).(ang{l}) = struct(); % Creates the joint and moment direction structure
        for i = 1:numel(subID)
            joint.(momDir{j}).(ang{l}).(subID{i}) = bd.(subID{i}).(subID{i}).(momDir{j}).(ang{l}); % Places subject information into structure
        end
    end
end

clear filePattern matFiles pathName x ang i j l matdata tempName

% Iterate over each field in the main structure
i = 1;

for j = 1:numel(momDir)
    % Get the fieldnames of the sub-structure
    angles = fieldnames(bd.(subID{1}).(subID{1}).(momDir{j})); % Determines the angles for the moment directions
    angles = sort(angles); % Organizes angles into descending order

    % Iterate over each field in the sub-structure
    for k = 1:numel(angles)

        sex = fieldnames(joint.(momDir{j}).(angles{k})); % Extracts subject IDs
        sex = string(sex); % Converts the IDs to strings
        m = contains(sex,'M'); % Determines if the subject is a male based on ID
        f = contains(sex,'F'); % Determines if the subject is a male based on ID

        % Iterate over each field in the sub-sub-structure
        for z = 1:length(subID)
            normM(z) = anthro.(subID{z}).General.Mass; % Determines mass for normalization (kg)
            normHM(z) = anthro.(subID{z}).General.Mass.*anthro.(subID{z}).General.Height./1000; % Determines height*mass for normalization (m*kg)
        end

        for z = 1:length(subID)
            dataR(z) = (joint.(momDir{j}).(angles{k}).(subID{z})(1)); % Variable for raw data
        end

        %% Data Splitting
        rfData = dataR(f'); rmData = dataR(m'); % Assigns sex to raw data

        %% Data Values
        data.Raw(i,:) = dataR; % Saves all raw data in a structure
        mNorm = dataR./normM; % Determines mass normalized data
        data.MNorm(i,:) = mNorm; % Saves all mass normalized data in the structure
        hmNorm = dataR./normHM; % Determines height-mass normalized data
        data.HMNorm(i,:) = hmNorm; % Saves all height-mass normalized data in the structures

        %% Single Values
        % Raw Values
        st.Raw.totalMax(k,j) = max(dataR); st.Raw.fMax(k,j) = max(rfData); st.Raw.mMax(k,j) = max(rmData);
        st.Raw.totalMean(k,j) = mean(dataR); st.Raw.fMean(k,j) = mean(rfData); st.Raw.mMean(k,j) = mean(rmData);
        st.Raw.totalStD(k,j) = std(dataR); st.Raw.fStD(k,j) = std(rfData); st.Raw.mStD(k,j) = std(rmData);
        st.Raw.totalRange(k,j) = max(dataR)-min(dataR); st.Raw.fRange(k,j) = max(rfData)-min(rfData); st.Raw.mRange(k,j) = max(rmData)-min(rmData);

        % Mass Normalized
        st.mNorm.totalMax(k,j) = max(mNorm); st.mNorm.fMax(k,j) = max(mNorm(f')); st.mNorm.mMax(k,j) = max(mNorm(m'));
        st.mNorm.totalMean(k,j) = mean(mNorm); st.mNorm.fMean(k,j) = mean(mNorm(f')); st.mNorm.mMean(k,j) = mean(mNorm(m'));
        st.mNorm.totalStD(k,j) = std(mNorm); st.mNorm.fStD(k,j) = std(mNorm(f')); st.mNorm.mStD(k,j) = std(mNorm(m'));
        st.mNorm.totalRange(k,j) = max(mNorm)-min(mNorm); st.mNorm.fRange(k,j) = max(mNorm(f'))-min(mNorm(f')); st.mNorm.mRange(k,j) = max(mNorm(m'))-min(mNorm(m'));

        % Height-Mass Normalized
        st.hmNorm.totalMax(k,j) = max(hmNorm); st.hmNorm.fMax(k,j) = max(hmNorm(f')); st.hmNorm.mMax(k,j) = max(hmNorm(m'));
        st.hmNorm.totalMean(k,j) = mean(hmNorm); st.hmNorm.fMean(k,j) = mean(hmNorm(f')); st.hmNorm.mMean(k,j) = mean(hmNorm(m'));
        st.hmNorm.totalStD(k,j) = std(hmNorm); st.hmNorm.fStD(k,j) = std(hmNorm(f')); st.hmNorm.mStD(k,j) = std(hmNorm(m'));
        st.hmNorm.totalRange(k,j) = max(hmNorm)-min(hmNorm); st.hmNorm.fRange(k,j) = max(hmNorm(f'))-min(hmNorm(f')); st.hmNorm.mRange(k,j) = max(hmNorm(m'))-min(hmNorm(m'));
        % Key
        st.key(k,j) = string(angles{k});
        i = i+1; % Iterates i for loop

    end

    st.key(5,j) = (momDir{j}); % Creates the key for easy data identification

end

clear angles anthro f fData intWidth j joint k KeyPath m mData momDir ncount norm numInt relFreq x z l
clear cfData cmData dataC R rfData rmData dataR  i normHM normM limbTor hmNorm mNorm subID sex

% %% Removal of torques without current volumes
% i = find(strcmp(subID,"M13"));
% data.Raw(:,i)=[]; data.Corrected(:,i)=[]; data.MNorm(:,i)=[]; data.HMNorm(:,i)=[];

clear i 