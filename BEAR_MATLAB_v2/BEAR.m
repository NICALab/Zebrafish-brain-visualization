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
function [W, options] = BEAR(Y, options)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Y: input matrix
%% options (input): hyperparameters
%% W: output matrix. The low rank component can be obtain as follows. L = W*(W'*Y).  Remember NOT to omit the paranthesis.
%% options (output): hyperparameters. Supposed to be the same as the input option, except the missing ones.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% start running BEAR
if nargin == 1
    options = struct;
end

if ~isfield(options, 'useGPU')
    options.useGPU = 0;
end
if ~isfield(options, 'Wstd') 
    options.Wstd = 0.001;
end
if ~isfield(options, 'target_rank')
    options.target_rank = 1;
end
if ~isfield(options, 'batch_size')
    options.batch_size = 32;
end
if ~isfield(options, 'num_epochs')
    options.num_epochs = 100;
end
if ~isfield(options, 'verbose')
    options.verbose = 1;
end
if ~isfield(options, 'learning_rate')
    options.learning_rate = 1e-5;
end
if ~isfield(options, 'momentum')
    options.momentum = 0.9;
end
if ~isfield(options, 'positivity')
    options.positivity = 0;
end
if ~isfield(options, 'lambda')
    options.lambda = 0.2;
end

useGPU  = options.useGPU;
Wstd = options.Wstd;
target_rank = options.target_rank;
batch_size = options.batch_size;
num_epochs = options.num_epochs;
verbose = options.verbose;
learning_rate = options.learning_rate;
momentum = options.momentum;
positivity = options.positivity;
lambda = options.lambda;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Y_size = size(Y);
imgsize = Y_size(1);
tlength = Y_size(2);

%% initialize W
if useGPU    
    W = gpuArray(Wstd*randn(imgsize, target_rank, 'single'));
else    
    W = Wstd*randn(imgsize, target_rank, 'single');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% main loop 
W_delta = 0;
n_batch = ceil(tlength/batch_size);

Y_small = Y(:,(1:min(batch_size, tlength)));
if positivity
    loss_norm = lambda*sum(abs(Y_small(:))) + sum(Y_small(:).^2);  
else
    loss_norm = sum(abs(Y_small(:)));
end

if useGPU   
    W_delta = gpuArray(W_delta);
    loss_norm = gpuArray(loss_norm);
end

for ei=1:num_epochs
    
    sample_seq = randperm(tlength);
    
    %% for each mini-batch
    for bi=1:n_batch
        
       %% load mini-batch
        current_batch = sample_seq( (bi-1)*batch_size + 1:  min(bi*batch_size + 1, tlength));
        batch_size_current = size(current_batch,2);
        if useGPU  
            Y_batch = gpuArray(Y(:, current_batch));
        else
            Y_batch = Y(:, current_batch);
        end

        %% forward pass
        z_batch = W'*Y_batch;                    %% z = WT*Y
        L_batch = W*z_batch;                     %% L = W*WT*Y
        
        if positivity
            S_batch = max(Y_batch - L_batch,0); %% ReLU
            Loss_batch = lambda*sum(abs(S_batch(:))) + sum((Y_batch(:) - L_batch(:)).^2);  
        else
            S_batch = Y_batch - L_batch;
            Loss_batch = sum(abs(S_batch(:)));            %% Loss = sum(abs(S))
        end
               
        
        %% backward pass
        if positivity
            dLoss_dL = -(Y_batch - L_batch) - lambda*single(S_batch>0);
        else
            dLoss_dS = sign(S_batch);
            dLoss_dL = -dLoss_dS;    
        end                            
        dL_dW = z_batch';
        dL_dz = W';        
        dLoss_dW = (dLoss_dL*dL_dW)/batch_size_current;
        dLoss_dz = dL_dz*dLoss_dL;        
        dz_dWT = Y_batch';
        dLoss_dWT = (dLoss_dz*dz_dWT)/batch_size_current;

        %% update
        gradient = dLoss_dW + dLoss_dWT';
        W_delta = momentum*W_delta + learning_rate*dLoss_dW;
        W = W - W_delta;
        
    end
    disp(['Epoch ' num2str(ei) ' | ' num2str(num_epochs) '. Loss : '  num2str(Loss_batch/loss_norm) ]);    
end

if useGPU  
    W = gather(W);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%