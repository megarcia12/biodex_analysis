% M3 Lab
% figCreate
% Created 29 August 2023
% Mario Garcia | nfq3bd@virginia.edu
clc;

%% File location
run("mvcComp.m")
path = ("C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Collected Data\Biodex\Biodex_Processed_Data\Torque_Regression_Tables.xlsx");
dirPath = ("C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Collected Data\Biodex\Biodex_Processed_Data\");
addpath(dirPath);

% Excel Function
writeToExcel = @(data, sheet, range) writematrix(data, path, 'Sheet', sheet, 'Range', range);

%% Ankle
ankleRanges = {'C5:C8', 'C21:C24', 'C37:C40', 'D5:D8', 'D21:D24', 'D37:D40'};
ankleData = [st.Raw.totalMean(:, 2), st.Raw.fMean(:, 2), st.Raw.mMean(:, 2), ... % Ankle Plantar Flexion
    st.Raw.totalMean(:, 1), st.Raw.fMean(:, 1), st.Raw.mMean(:, 1)]; % Ankle Dorsiflexion
for i = 1:length(ankleRanges)
    writeToExcel(ankleData(:, i), 'Tables', ankleRanges{i});
end

%% Knee
kneeRanges = {'F5:F8', 'F21:F24', 'F37:F40', 'G5:G8', 'G21:G24', 'G37:G40'};
kneeData = [st.Raw.totalMean(:, 7), st.Raw.fMean(:, 7), st.Raw.mMean(:, 7), ... % Knee Extension
    st.Raw.totalMean(:, 8), st.Raw.fMean(:, 8), st.Raw.mMean(:, 8)]; % Knee Flexion
for i = 1:length(kneeRanges)
    writeToExcel(kneeData(:, i), 'Tables', kneeRanges{i});
end

%% Hip
hipRanges = {'I5:I7', 'I21:I24', 'I37:I40', 'J5:J7', 'J21:J24', 'J37:J40', ...
    'L5:L7', 'L21:L24', 'L37:L40', 'M5:M7', 'M21:M24', 'M37:M40'};
hipData = [st.Raw.totalMean(1:3, 6), st.Raw.fMean(1:3, 6), st.Raw.mMean(1:3, 6), ... % Hip Flexion
    st.Raw.totalMean(1:3, 5), st.Raw.fMean(1:3, 5), st.Raw.mMean(1:3, 5), ... % Hip Extension
    st.Raw.totalMean(1:3, 3), st.Raw.fMean(1:3, 3), st.Raw.mMean(1:3, 3), ... % Hip Abduction
    st.Raw.totalMean(1:3, 4), st.Raw.fMean(1:3, 4), st.Raw.mMean(1:3, 4)]; % Hip Adduction
for i = 1:length(hipRanges)
    writeToExcel(hipData(:, i), 'Tables', hipRanges{i});
end

%% Variable Clearing
clear path writeToExcel ankleRanges ankleData kneeRanges kneeData hipRanges hipData
