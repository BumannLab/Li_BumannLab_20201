function [Ttotal,TOpt] = NumberObjectsPerImage(read_dir)
A = readtable(fullfile(read_dir,'Allpositions_filter3D.txt'));
frames = max(A.Frame);
opt = max(A.Optical);

k=1;
NumObjects = zeros(frames*opt,1);
for i=1:frames
    for j=1:opt
        NumObjects(k) = sum(A.Frame==i & A.Optical==j);
        k = k+1;
    end
end
Frame = reshape(repmat(1:frames,opt,1),1,frames*opt)';
Opt = repmat(1:opt, 1,frames)';
Ttotal = table(Frame,Opt,NumObjects);   

k=1;
NumObjectsOpt = zeros(opt,1);
for j=1:opt
    NumObjectsOpt(k) = sum(A.Optical==j);
    k = k+1;
end
Opt = (1:opt)';
TOpt = table(Opt,NumObjectsOpt);