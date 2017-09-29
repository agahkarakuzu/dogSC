disp('Reading data and performing statistics');
setNifti; 
pkg load image;
pkg load statistics; 
pkg load optim;

curdir = pwd;
cd('/home/jovyan/work');
unix('tar -xvf /home/jovyan/work/dogSC_data.tar.gz');
addpath('/home/jovyan/work/Users/Agah/Desktop/OctaveJN/scn_rscn');
cd(curdir);

% ------------------ READ AND LOAD ------------------ START
warning('off');


scan = struct();
rescan = struct();
mask = struct();

scan.mwf  = cbiReadNifti('mwf_scan.nii');
scan.mtv  = cbiReadNifti('mtv_scan.nii');
scan.fsir = cbiReadNifti('Fsir_scan.nii');
scan.spgr = cbiReadNifti('Fspgr_scan.nii');

rescan.mwf  = cbiReadNifti('mwf_rescan.nii');
rescan.mtv  = cbiReadNifti('mtv_rescan.nii');
rescan.fsir = cbiReadNifti('Fsir_rescan.nii');
rescan.spgr = cbiReadNifti('Fspgr_rescan.nii');

mask.wm  = cbiReadNifti('mask_wm_scan.nii'); 
mask.sc =  cbiReadNifti('mask_wsc_scan.nii');

load MVF_histo_reg.mat; % This will load histology image which is registered on MR images. 

wmMask = logical(mask.wm.data);
scMask = logical(mask.sc.data);

imCorScan  = struct();
imCorRescan  = struct();

imCorScan(1).im = histo_reg;
imCorScan(1).name = 'Histo';
imCorScan(1).wmVec = imCorScan(1).im(wmMask);
imCorScan(1).scVec = imCorScan(1).im(scMask);
imCorScan(2).im = scan.mwf.data; %mwf_scan
imCorScan(2).name = 'MWF #1';
imCorScan(2).wmVec = imCorScan(2).im(wmMask);
imCorScan(2).scVec = imCorScan(2).im(scMask);
imCorScan(3).im = scan.mtv.data;
imCorScan(3).name = 'MTV #1';
imCorScan(3).wmVec = imCorScan(3).im(wmMask);
imCorScan(3).scVec = imCorScan(3).im(scMask);
imCorScan(4).im = scan.fsir.data;
imCorScan(4).name = 'SIRFSE #1';
imCorScan(4).wmVec = imCorScan(4).im(wmMask);
imCorScan(4).scVec = imCorScan(4).im(scMask);
imCorScan(5).im = scan.spgr.data;
imCorScan(5).name = 'SPGR #1';
imCorScan(5).wmVec = imCorScan(5).im(wmMask);
imCorScan(5).scVec = imCorScan(5).im(scMask);


fid = fopen('Scan_names.csv','wt');
if fid>0
for k=1:5
if k==1
fprintf(fid,'%s,\n%f','name');
fprintf(fid,'%s,\n%f',imCorScan(k).name);
else
fprintf(fid,'%s,\n%f',imCorScan(k).name);
end
end
fclose(fid);
end


imCorRescan(1).im = histo_reg;
imCorRescan(1).name = 'Histo';
imCorRescan(1).wmVec = imCorRescan(1).im(wmMask);
imCorRescan(1).scVec = imCorRescan(1).im(scMask);
imCorRescan(2).im = rescan.mwf.data; %mwf_rescan
imCorRescan(2).name = 'MWF #2';
imCorRescan(2).wmVec = imCorRescan(2).im(wmMask);
imCorRescan(2).scVec = imCorRescan(2).im(scMask);
imCorRescan(3).im = rescan.mtv.data;
imCorRescan(3).name = 'MTV #2';
imCorRescan(3).wmVec = imCorRescan(3).im(wmMask);
imCorRescan(3).scVec = imCorRescan(3).im(scMask);
imCorRescan(4).im = rescan.fsir.data;
imCorRescan(4).name = 'SIRFSE #2';
imCorRescan(4).wmVec = imCorRescan(4).im(wmMask);
imCorRescan(4).scVec = imCorRescan(4).im(scMask);
imCorRescan(5).im = rescan.spgr.data;
imCorRescan(5).name = 'SPGR #2';
imCorRescan(5).wmVec = imCorRescan(5).im(wmMask);
imCorRescan(5).scVec = imCorRescan(5).im(scMask);

fid = fopen('Rescan_names.csv','wt');
if fid>0
for k=1:5
if k==1
fprintf(fid,'%s,\n%f','name');
fprintf(fid,'%s,\n%f',imCorRescan(k).name);
else
fprintf(fid,'%s,\n%f',imCorRescan(k).name);
end
end
fclose(fid);
end

scanCorMatrix_wm = zeros(5,5);
scanCorMatrix_sc = zeros(5,5);
rescanCorMatrix_wm = zeros(5,5); 
rescanCorMatrix_sc = zeros(5,5); 


for i=1:5
for j=1:5
scanCorMatrix_wm(i,j) = corr(imCorScan(i).wmVec,imCorScan(j).wmVec);
scanCorMatrix_sc(i,j) = corr(imCorScan(i).scVec,imCorScan(j).scVec);
rescanCorMatrix_wm(i,j) = corr(imCorRescan(i).wmVec,imCorRescan(j).wmVec);
rescanCorMatrix_sc(i,j) = corr(imCorRescan(i).scVec,imCorRescan(j).scVec);
end
end

save -mat7-binary 'CorrelationMatrices.mat' 'scanCorMatrix_wm' 'scanCorMatrix_sc' 'rescanCorMatrix_wm' 'rescanCorMatrix_sc'
save -mat7-binary 'strData.mat' 'imCorRescan' 'imCorScan'

% ------------------ CALCULATE WITHIN SESSIONS CORRELATION MATRIX ------------------ END


% ------------------ CALCULATE BETWEEN SESSIONS CORRELATION MATRIX ------------------ START

imCor  = struct();
imCor(1).im = histo_reg;
imCor(1).name = 'Histo';
imCor(2).im = scan.mwf.data; %mwf_scan
imCor(2).name = 'MWF #1';
imCor(3).im = rescan.mwf.data; %mwf_rescan
imCor(3).name = 'MWF #2';
imCor(4).im = scan.mtv.data;
imCor(4).name = 'MTV #1';
imCor(5).im = rescan.mtv.data;
imCor(5).name = 'MTV #2';
imCor(6).im = scan.fsir.data;
imCor(6).name = 'SIRFSE #1';
imCor(7).im = rescan.fsir.data;
imCor(7).name = 'SIRFSE #2';
imCor(8).im = scan.spgr.data;
imCor(8).name = 'SPGR #1';
imCor(9).im = rescan.spgr.data;
imCor(9).name = 'SPGR #2';

a = [1 3 5 7 9];
fid = fopen('session1Names.csv','wt');
if fid>0
for k=1:5
if k==1
fprintf(fid,'%s,\n%f','name');
fprintf(fid,'%s,\n%f',imCor(a(k)).name);
else
fprintf(fid,'%s,\n%f',imCor(a(k)).name);
end
end
fclose(fid);
end

b = [1 2 4 6 8]; 
fid = fopen('session2Names.csv','wt');
if fid>0
for k=1:5
if k==1
fprintf(fid,'%s,\n%f','name');
fprintf(fid,'%s,\n%f',imCor(b(k)).name);
else
fprintf(fid,'%s,\n%f',imCor(b(k)).name);
end
end
fclose(fid);
end


[A,B] = meshgrid(a,b);
c=cat(2,A',B');
d=reshape(c,[],2);

wmCor_coef = zeros(length(d),1);
for i=1:length(d)
v1 = imCor(d(i,1)).im;
v2 = imCor(d(i,2)).im;
wmCor_coef(i,1) = corr(v1(wmMask),v2(wmMask));
scCor_coef(i,1) = corr(v1(scMask),v2(scMask));
end


wmCor_matrix = reshape(wmCor_coef,[5 5]);
scCor_matrix = reshape(scCor_coef,[5 5]);

save -mat7-binary 'betweenSessionCM.mat' 'wmCor_matrix' 'scCor_matrix' 'imcor'