%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BEAR: Bilinear neural network for Efficient Approximation of RPCA, MICCAI, 2021
%% Seungjae Han,  Eun-Seo Cho, Inkyu Park, Kijung Shin and Young-Gyu Yoon, KAIST
%% https://github.com/NICALab/BEAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This is a MATLAB implementation of BEAR for wider distribution of the algorithm.
%% The original implementation of BEAR in Python can be found at https://github.com/NICALab/BEAR.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Citation
%% @inproceedings{han2021efficient,
%%  title={Efficient neural network approximation of robust PCA for automated analysis of calcium imaging data},
%%  author={Seungjae Han and Eun-Seo Cho and Inkyu Park and Kijung Shin and Young-Gyu Yoon},
%%  booktitle={International Conference on Medical Image Computing and Computer Assisted Intervention},
%%  year={2021}
%% }
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% specify TIFF file to load
inputFile = './Data/rawVideo_210418_Casper_GCaMP7a_4dpf_sample1_frame029.tif';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load data
Finfo = imfinfo(inputFile);
tlength = numel(Finfo);
currentSlice = single(imread(inputFile, 1));
imgResolution_raw = size(currentSlice);
figure; imshow(currentSlice/max(currentSlice(:)));

source_video = zeros( imgResolution_raw(1), imgResolution_raw(2), tlength, 'single');
for ti=1:tlength
    currentSlice = single(imread(inputFile, ti));
    source_video( 1:end, 1:end ,ti) = currentSlice;
end

%% crop
% source_video_crop = source_video( :,(129:384),:);
source_video_crop = source_video( :,:,:);
imgResolution = [size(source_video_crop,1) size(source_video_crop,2)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% reshape data into a matrix
Y_size = [imgResolution(1)*imgResolution(2), tlength];
Y = reshape(source_video_crop/max(source_video_crop(:)),  imgResolution(1)*imgResolution(2), tlength);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X = reshape(tStack, [prod(imageResolution), tlength]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% hyper parameters
opt.useGPU = 1;
opt.batch_size  = 16;
opt.num_epochs = 50;
opt.learning_rate = 1e-5;
opt.momentum = 0.9;
opt.target_rank = 2;
opt.positivity = 1;
opt.lambda = 0.2; %% larger lambda enforces "stronger" sparsity. only works when positivity = 1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% run BEAR
[W, opt] = BEAR(Y, opt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% display results
Ynorm = max(Y(:));

figure(1);
for ti=1:tlength
    Y_current = Y(:,ti);
    L_current = W*(W'*Y_current);
    S_current = Y_current - L_current;
    
    Y_current = reshape(Y_current, imgResolution(1), imgResolution(2));
    L_current = reshape(L_current, imgResolution(1), imgResolution(2));
    S_current = reshape(S_current, imgResolution(1), imgResolution(2));
    figure(1);
    Y_img(:,:,ti) = Y_current;
    L_img(:,:,ti) = L_current;
    S_img(:,:,ti) = S_current;
    subplot(1,3,1); imshow(Y_current/Ynorm);
    subplot(1,3,2); imshow(L_current/Ynorm);
    subplot(1,3,3); imshow(3*S_current/Ynorm);
    drawnow;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% save results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L_img_tMIP = max(L_img,[],3);

saveNorm = max(L_img_tMIP(:));
saveL = 65535*L_img./saveNorm;
saveL = uint16(saveL);
saveName = ['L_img.tif'];
imwrite(saveL(:,:,1),saveName);
for i=2:size(saveL,3)
    imwrite(saveL(:,:,i),saveName,'Writemode', 'append')
end

saveS = 65535*S_img./saveNorm;
saveS = uint16(saveS);
saveName = ['S_img.tif'];
imwrite(saveS(:,:,1),saveName);
for i=2:size(saveS,3)
    imwrite(saveS(:,:,i),saveName,'Writemode', 'append')
end