function timerCaller()
    % 创建定时器对象
    t = timer;
    t.Period = 3; % 3秒周期
    t.ExecutionMode = 'fixedRate'; % 固定速率执行
    t.TimerFcn = @(~,~)runExternalMatlabScript();
    
    % 启动定时器
    start(t);
    fprintf('定时器已启动，每3秒调用一次外部MATLAB程序\n');
    fprintf('按任意键停止...\n');
    pause;
    
    % 清理定时器
    stop(t);
    delete(t);
end

function runExternalMatlabScript()
    % 替换为您的MATLAB程序路径
    scriptPath = saveNew();
    
    try
        fprintf('调用saveNew: %s\n', scriptPath);
        run(scriptPath);
        fprintf('调用成功\n');
    catch ME
        fprintf('调用失败: %s\n', ME.message);
    end

    scriptPath = ex3;
    
    try
        fprintf('调用ex3: %s\n', scriptPath);
        run(scriptPath);
        fprintf('调用成功\n');
    catch ME
        fprintf('调用失败: %s\n', ME.message);
    end
end