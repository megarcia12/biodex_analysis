% M3 Lab
% quintileAssign.m
% Created 12 October 2023
% Mario Garcia | nfq3bd@virginia.edu

%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 21);
% Specify sheet and range
opts.Sheet = "UseThisSheet";
opts.DataRange = "A5:U104";
% Specify column names and types
opts.VariableNames = ["VarName1", "PhysicalProperties", "VarName3", "HispanicOrigin", "Race", "ETHNIC", "HEIGHTMASS", "RACIAL", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "FORMULASCALCULATIONS", "VarName17", "VarName18", "VarName19", "VarName20", "VarName21"];
opts.VariableTypes = ["string", "double", "double", "categorical", "categorical", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "double", "double", "double","double", "double", "double"];
% Specify variable properties
opts = setvaropts(opts, ["VarName1", "ETHNIC", "HEIGHTMASS", "RACIAL", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["VarName1", "HispanicOrigin", "Race", "ETHNIC", "HEIGHTMASS", "RACIAL", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName17", "VarName18", "VarName19", "VarName20", "VarName21"], "EmptyFieldRule", "auto");
% Import the data
TrialTracker = readtable("C:\Users\nfq3bd\Box\R01 Sex Specific Modeling\00_ProjectManagement&GrantDocuments\Trial_Tracker.xlsx", opts, "UseExcel", false);

%% Table to array
for i = 1:14
    TrialTracker(:,2) = [];
end
TrialTracker = rmmissing(table2array(TrialTracker));
[row,col] = size(TrialTracker);
for m = 1:row
    for n = 1:col
        rTable(m,n) = str2double(TrialTracker(m,n));
    end
end
rTable(:,1) = [];
qTable(:,1) = rTable(:,1);
for i = 1:row
    qTable(i,2) = sum(rTable(i,2:end));
end
TrialTracker(:,2:end) = [];
qTable = [TrialTracker,qTable];

%% Clear temporary variables
clear opts col i m n row rTable TrialTracker