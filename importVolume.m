
pathName = 'C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Data\Biodex\Muscle Volumes'; % Select folder containing data
Files = dir(fullfile(pathName,'*.txt'));
Files = {Files.name}';

%% File Names
fn=regexp(Files,'\w*(?=.txt)','match');
fnames = [fn{:,:}]';

%% Import Data
opts = delimitedTextImportOptions("NumVariables", 9);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["GroupStructureName", "Type", "Asymmetry", "SBScore", "VolumeScore", "FatInfiltration", "RawVolumeml", "Heightm", "Weightkg"];
opts.VariableTypes = ["string", "categorical", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "GroupStructureName", "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["GroupStructureName", "Type"], "EmptyFieldRule", "auto");

% Import the data
for i = 1:size(fnames)
tempName = horzcat(pathName,'\',(Files{i}));
raw = readtable(tempName, opts);
vol.(fnames{i}).R = raw;
vol.(fnames{i}).H = table2array(raw(1,end-1));
vol.(fnames{i}).M = table2array(raw(1,end));
raw(:,end) = []; raw(:,end) = [];
rawVol = table2array(raw(:,end));
rawFI = table2array(raw(:,6));
% Hip
k = 4;
Volume = []; Infiltration = []; Corrected = [];
ROI = {'Full Hip';'Flexors';'Extensors';'Abductors';'Adductors'};
for j = 1:5
    Volume = [Volume;rawVol(k)];
    Infiltration = [Infiltration;rawFI(k)];
    Corrected = [Corrected;rawVol(k) - (rawVol(k)/100)*rawFI(k)];
    k = k +2;
end
cTable = table(ROI,Volume,Infiltration,Corrected);
vol.(fnames{i}).Hip = cTable;
% Knee
k = 18;
Volume = []; Infiltration = []; Corrected = [];
ROI = {'Full Knee';'Flexors';'Extensors'};
for j = 1:3
    Volume = [Volume;rawVol(k)];
    Infiltration = [Infiltration;rawFI(k)];
    Corrected = [Corrected;rawVol(k) - (rawVol(k)/100)*rawFI(k)];
    k = k +2;
end
cTable = table(ROI,Volume,Infiltration,Corrected);
vol.(fnames{i}).Knee = cTable;
% Ankle
k = 24;
Volume = []; Infiltration = []; Corrected = [];
ROI = {'Full Ankle';'Dorsiflexors';'Plantar Flexors'};
for j = 1:3
    Volume = [Volume;rawVol(k)];
    Infiltration = [Infiltration;rawFI(k)];
    Corrected = [Corrected;rawVol(k) - (rawVol(k)/100)*rawFI(k)];
    k = k +2;
end
cTable = table(ROI,Volume,Infiltration,Corrected);
vol.(fnames{i}).Ankle = cTable;
end
clear Corrected cTable Files fn fnames i Infiltration j k opts pathName raw rawFI rawVol ROI tempName Volume
