function [scriptPath] = saveNew()
    %% ========== 1. 加载数据 ==========
    load('Exp1.mat'); % Measurement 原始数据
    
    % 遍历 Measurement，直接过滤
    for i = 1:size(Measurement, 2)
        data = Measurement{1, i};  % 3 x N
        label = Measurement{2, i}; % scalar
    
        if ~isempty(data) && ~isempty(label)
            if size(data, 1) == 3
                x = data(1, :);
                y = data(2, :);
    
                % 保留 x ∈ [-1300, -800] 且 y ∈ [-1550, -1050] 的点
                mask = (x >= -1300 & x <= -850) & ...
                       (y >= -1550 & y <= -1050);
    
                % 更新 Measurement 中的数据
                Measurement{1, i} = data(:, mask);
            end
        end
    end
    
    % 保存新的文件
    scriptPath = 'Exp1_filtered.mat';
    save('Exp1_filtered.mat', 'Measurement');
    disp('已生成 Exp1_filtered.mat（原 Measurement 已按条件更新）');
end
