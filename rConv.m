% M3 Lab
% rConv.m
% Created 20 September 2023
% Mario Garcia | nfq3bd@virginia.edu

%% Run Relevant Files
run("mvcComp.m");

%% Create Row and Column Names
cNames = fieldnames(bd)';
rNames = {'Ankle Df 0','Ankle Df 15','Ankle Df 30','Ankle Df 45',...
    'Ankle Pf 0','Ankle Pf 15','Ankle Pf 30','Ankle Pf 45',...
    'Hip Ab 0','Hip Ab 10','Hip Ab 20',...
    'Hip Ad 0','Hip Ad 10','Hip Ad 20',...
    'Hip Ex 0','Hip Ex 15','Hip Ex 30',...
    'Hip Fx 0','Hip Fx 15','Hip Fx 30',...
    'Knee Ex 15','Knee Ex 40','Knee Ex 65','Knee Ex 90.',...
    'Knee Fx 15','Knee Fx 40','Knee Fx 65','Knee Fx 90'};

%% Create Table
T = array2table(data.Raw,'VariableNames',cNames,'RowNames',rNames);
tablePath = 'C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Collected Data\Biodex\BiodexData.csv';
writetable(T,tablePath,'WriteRowNames',true);

%% Vars Clearing
clear cNames rNames tablePath 