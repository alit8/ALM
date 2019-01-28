clear ; close all; clc

% data = load('data_sinc.txt');
data = load('data_sinc_2.txt');
% data = load('data_saddle.txt');
% data = load('data_saddle_2.txt');
k = size(data, 2) - 1; % number of premise variables
X_train = data(:, 1:k);
Y_train = data(:, k+1);
m_train = length(Y_train); % number of examples

% data_test = load('data_sinc_test.txt');
data_test = load('data_sinc_test_2.txt');
% data_test = load('data_saddle_test.txt');
% data_test = load('data_saddle_test_2.txt');;
X_test = data_test(:, 1:k);
y_test = data_test(:, k+1);
m_test = length(y_test);
y_ = zeros(m_test, 1);

rngX = cell(1, k);
np = cell(1, k);
sp = cell(1, k);
spread = zeros(1, k);

showfigs = 1;

for i = 1:k
    Xin = X_train(:, i);
    Yin = Y_train;
    
    [rngX{i}, np{i}, sp{i}] = ids(Xin, Yin, showfigs);   
    
    spread(i) = mean(sp{i});
    i
end
    
[spread idx] = sort(spread);

M = [];
fis = newfis('model', 'sugeno', 'min', 'max', 'prod', 'max', 'wtaver');
% fis = addOutput(fis, [-10 10]);
if (k == 2 || k == 4)
    L = 10;
    fis = addvar(fis, 'output', 'y', [-L, L]);
else
    L = 3;
    fis = addvar(fis, 'output', 'y', [-L, L]);
end
%opt = genfisOptions('GridPartition');
%opt.NumMembershipFunctions = [];
%opt.InputMembershipFunctionType = [];

err = inf;

np_test = zeros(m_test, k);
sp_test = zeros(m_test, k);
w_test = zeros(m_test, k);

for i = 1:k
    M = [M, idx(i)];
    
    fis = addvar(fis, 'input', ['x', num2str(idx(i))], [rngX{idx(i)}(1), rngX{idx(i)}(end)]);
    fis = addmf(fis, 'input', i, ['x', num2str(idx(i)), '1'], 'trapmf', [-inf -inf inf inf]);
    
    irule = zeros(1, i);
    
    for j = 1:m_test
        irule(i) = 1;
        np_test(j, i) = interp1(rngX{idx(i)}, np{idx(i)}, X_test(j, idx(i)));
        sp_test(j, i) = interp1(rngX{idx(i)}, sp{idx(i)}, X_test(j, idx(i)));
        w_test(j, i) = 1/sp_test(j, i);

        if ~isnan(np_test(j, i)) && ~isnan(sp_test(j, i))
            fis = addmf(fis, 'output', 1, num2str(np_test(j, i)), 'constant', np_test(j, i));
            %fis = addmf(fis, 'input', i, num2str(X_test(j, idx(i))), 'constant', X_test(j, idx(i)));
            fis = addrule(fis, [irule, getfis(fis, 'numoutputmfs'), w_test(j, i), 1]);
        end
        %y_(j) = evalfis(X_test(j, M), fis);
    end
    
    y_ =  (L/3) * sum(w_test .* np_test, 2)./sum(w_test, 2);
    
    showrule(fis)
    
    if (mean((y_ - y_test).^2) <= err)
        err = mean((y_ - y_test).^2);
    else
        M = M(1:end-1);
        break;
    end

end
