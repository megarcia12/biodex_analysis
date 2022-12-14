function angles = angleImport(filename, dataLines)
%IMPORTFILE Import data from a text file
%  EMSTFX = IMPORTFILE(FILENAME) reads data from text file FILENAME for
%  the default selection.  Returns the data as a table.
%
%  EMSTFX = IMPORTFILE(FILE, DATALINES) reads data for the specified row
%  interval(s) of text file FILENAME. Specify DATALINES as a positive
%  scalar integer or a N-by-2 array of positive scalar integers for
%  dis-contiguous row intervals.
%
%  Example:
%  emstfx = importfile("C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Biodex\Biodex Data\10_14_2022\em_st_fx.txt", [37, 37]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 21-Oct-2022 10:33:41

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [37, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 8, "Encoding", "UTF-8");

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = " ";

% Specify column names and types
opts.VariableNames = ["Var1", "Away", "Toward", "Away1", "Toward1", "Away2", "Var7", "Var8"];
opts.SelectedVariableNames = ["Away", "Toward", "Away1", "Toward1", "Away2"];
opts.VariableTypes = ["char", "double", "double", "double", "double", "double", "char", "char"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% Specify variable properties
opts = setvaropts(opts, ["Var1", "Var7", "Var8"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Var7", "Var8"], "EmptyFieldRule", "auto");

% Import the data
a= readtable(filename, opts);
idx = ~isnan(a{1,:}) ; 
angles = a{1,idx} ; 

end