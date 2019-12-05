function [T,id] = sortNamesByMode(ID,ParamTable,level)
% This function summs up all the detected objects acoording of the level of
% precision in the brain tree.

% load the data base
ARA_LIST = getAllenStructureList;

if nargin<2
    level = max(ARA_LIST.depth);
elseif level>max(ARA_LIST.depth)
    error('Maximum level is %i', max(ARA_LIST.depth));
end

% change the name according to the level of depth
ID_new = zeros(size(ID));
f_delete = [];
for i = 1:length(ID)
    a = ID(i);
    f=find(ARA_LIST.id == a); % index in the structure
    if ~isempty(f)
        while ARA_LIST.depth(f)> level
            a = ARA_LIST.parent_structure_id(f);% the upper layer in the tree
            f=find(ARA_LIST.id == a);
        end
    else
        % delete entry if no such id (brain part) exist
        f_delete = [f_delete;i];% indeces outside the brain
    end
    ID_new(i) =  a;
end
ID_new(f_delete) = [];% indeces that corresponds to the level in the tree
ParamTable(f_delete,:) = [];
name_level = sprintf('ID_level%i',level);
ParamTable = addvars(ParamTable,ID_new','NewVariableNames',name_level);
if ~mkdir(fullfile('data_analysis',sprintf('ID_level%i',level)))
end
[a,b] = mode(ID_new);
fprintf('The largest amount of toxo is in the %s area.\n', structureID2name(a));
% make a table with names

IDnames = cell(1,1); k =1;
IDnum = []; id = [];
Id_tmp = ID_new;
while ~isempty(ID_new)
    [a,b] = mode(ID_new);%[value, frequency]
    IDnames{k} = structureID2name(a);
    IDnum = [IDnum; b]; % number of toxo
    id = [id;a];
    ParamTable_level = ParamTable(Id_tmp==a,:);
    writetable(ParamTable_level,fullfile('data_analysis',sprintf('ID_level%i',level),sprintf('Objects_for_id_%i.txt',a)));
    k = k+1;
    ID_new(ID_new==mode(ID_new)) = [];
end
T = table(IDnames', IDnum, id,'VariableNames', {'brain_part_name'; 'number_of_toxo';'ID'})