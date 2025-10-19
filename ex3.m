%% 实测数据编队检测+中心点轨迹
clear; close all; clc;

load('Exp1.mat'); % Measurement
%% Step 1: 按 label 整理轨迹
valid_tracks = {};
track_labels = [];

for i = 1:size(Measurement,2)
    data = Measurement{1,i};  % 3 x N
    label = Measurement{2,i}; % scalar

    if ~isempty(data) && ~isempty(label) && size(data,1) == 3
        valid_tracks{end+1} = data;
        track_labels(end+1) = label;
    end
end

unique_labels = unique(track_labels);
fprintf('有效帧数: %d\n', length(unique_labels));

%% Step 2: 动画显示
formation_centers = [];
formation_label = [];

figure;
set(gcf, 'Position', [100, 100, 800, 600]);
axis equal; grid on;
xlabel('X (m)'); ylabel('Y (m)');
title('无人机编队检测（按 label 分帧）');
hold on;

trail_plot = plot(nan, nan, 'r-', 'LineWidth', 2);
center_dot = plot(nan, nan, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
time_text = text(0, 0, '', 'FontSize', 12, 'Color', 'b');
point_plot = [];
hull_plot = [];

for li = 1:length(unique_labels)
    label_now = unique_labels(li);
    positions = [];

    % 收集当前帧所有轨迹点
    for j = 1:length(track_labels)
        if track_labels(j) == label_now
            traj = valid_tracks{j};
            positions = [positions, traj(1:2, :)];
        end
    end

    if size(positions, 2) < 2
        fprintf('label=%d: 点数不足\n', label_now);
        continue;
    end

    pts = positions';

    % DBSCAN 参数
    D = pdist(pts);
    avgDist = mean(D);
    epsilon = max(avgDist * 1.5, 2);
    minpts = max(3, ceil(size(pts,1)*0.2));

    labels = dbscan(pts, epsilon, minpts);
    cluster_ids = unique(labels(labels > 0));
    if isempty(cluster_ids)
        fprintf('label=%d: 无有效簇\n', label_now);
        continue;
    end

    % 最大簇
    cluster_sizes = arrayfun(@(id) sum(labels == id), cluster_ids);
    [~, max_idx] = max(cluster_sizes);
    main_cluster_id = cluster_ids(max_idx);
    formation_pts = pts(labels == main_cluster_id, :);

    center = mean(formation_pts, 1)';
    formation_centers(:, end+1) = center;
    formation_label(end+1) = label_now;

    % 清除旧图形
    if ~isempty(point_plot), delete(point_plot); end
    if ~isempty(hull_plot), delete(hull_plot); end

    % 所有点灰色
    plot(pts(:,1), pts(:,2), 'o', 'Color', [0.7 0.7 0.7], 'MarkerSize', 5);
    % 编队点蓝色
    point_plot = plot(formation_pts(:,1), formation_pts(:,2), 'bo', ...
                      'MarkerFaceColor', 'b', 'MarkerSize', 6);
    % 编队凸包
    if size(formation_pts, 1) >= 3
        k = convhull(formation_pts(:,1), formation_pts(:,2));
        hull_plot = plot(formation_pts(k,1), formation_pts(k,2), 'g-', 'LineWidth', 1.5);
    end

    % 更新轨迹线
    set(trail_plot, 'XData', formation_centers(1,:), ...
                    'YData', formation_centers(2,:));
    % 更新当前中心
    set(center_dot, 'XData', center(1), 'YData', center(2));
    % 更新时间/帧号
    set(time_text, 'Position', center + [1; 1], ...
                   'String', sprintf('Label: %d', label_now));

    xlim([-1300, -800]);
    ylim([-1550,-1050]);
    drawnow;
    pause(0.2);
end

%% Step 3: 最终轨迹
if ~isempty(formation_centers)
    plot(formation_centers(1, :), formation_centers(2, :), 'r-', 'LineWidth', 2);
    legend({'中心轨迹', '当前中心点', '编队成员', '编队凸包'}, 'Location', 'best');
else
    warning('formation_centers为空，DBSCAN未检测到编队');
end
