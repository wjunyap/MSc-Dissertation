%% ============================================================
% Read three CSVs, align time, and check:
%   F_whole(t) = F_dike(t) + F_parapet(t)
% Also decompose the global peak into dike/parapet contributions.
% ============================================================

% ---- File names (edit if needed, case-sensitive on some systems)
fnD = '_DikeForceDike.csv';
fnP = '_DikeForceParapet.csv';   % change if your file is named e.g. '_DikeForceparapet.csv'
fnW = '_DikeForceWhole.csv';

% ---- Optional time window (set [] to use all)
tmin = [];   % e.g., 10
tmax = [];   % e.g., 20

% ---- Tolerance for additivity residual (N/m)
tol_abs = 1e-2;

% ---- Helper: robust CSV read + variable detection
readForceCsv = @(fn) local_read_force_csv(fn);

[time_d, Fx_d] = readForceCsv(fnD);
[time_p, Fx_p] = readForceCsv(fnP);
[time_w, Fx_w] = readForceCsv(fnW);

% ---- Apply optional time window
[time_d, Fx_d] = local_apply_window(time_d, Fx_d, tmin, tmax);
[time_p, Fx_p] = local_apply_window(time_p, Fx_p, tmin, tmax);
[time_w, Fx_w] = local_apply_window(time_w, Fx_w, tmin, tmax);

% ---- Align on a common time vector (round to 1e-4 s to avoid FP mismatches)
rt = @(t) round(t*1e4)/1e4;
Td2 = table(rt(time_d), Fx_d, 'VariableNames', {'t','Fx_d'});
Tp2 = table(rt(time_p), Fx_p, 'VariableNames', {'t','Fx_p'});
Tw2 = table(rt(time_w), Fx_w, 'VariableNames', {'t','Fx_w'});

M = innerjoin(innerjoin(Td2, Tp2, 'Keys','t'), Tw2, 'Keys','t');
t    = M.t; 
Fx_d = M.Fx_d; 
Fx_p = M.Fx_p; 
Fx_w = M.Fx_w;

if isempty(t)
    error('No common timestamps after alignment. Check file names/time windows.');
end

% ---- Additivity check
residual = Fx_w - (Fx_d + Fx_p);
abs_res  = abs(residual);

fprintf('Additivity over %d common timesteps:\n', numel(t));
fprintf('  Mean |residual|  = %.6f N/m\n', mean(abs_res));
fprintf('  Max  |residual|  = %.6f N/m\n', max(abs_res));

[abs_max, imax] = max(abs_res);
fprintf('  Worst at t = %.6f s:\n', t(imax));
fprintf('     F_whole = %.6f,  F_dike = %.6f,  F_parapet = %.6f,  sum = %.6f,  residual = %.6f\n', ...
        Fx_w(imax), Fx_d(imax), Fx_p(imax), Fx_d(imax)+Fx_p(imax), residual(imax));

if any(abs_res > tol_abs)
    fprintf('  WARNING: %d timesteps exceed tolerance (|residual| > %.3g N/m).\n', sum(abs_res>tol_abs), tol_abs);
else
    fprintf('  OK: All timesteps within tolerance (%.3g N/m).\n', tol_abs);
end

% ---- Decompose the GLOBAL whole-structure peak
[~, ipeak] = max(Fx_w);
t_peak   = t(ipeak);
F_w_pk   = Fx_w(ipeak);
F_d_pk   = Fx_d(ipeak);
F_p_pk   = Fx_p(ipeak);
share_p  = F_p_pk / F_w_pk;

fprintf('\nGlobal peak decomposition:\n');
fprintf('  t_peak = %.6f s,  F_whole = %.3f N/m\n', t_peak, F_w_pk);
fprintf('  Components at t_peak:  F_dike = %.3f,  F_parapet = %.3f,  share_parapet = %.2f\n', F_d_pk, F_p_pk, share_p);

% ---- (Optional) Plots
figure('Color','w','Position',[100 100 820 340]);
plot(t, Fx_w, 'k-', 'LineWidth', 1.2); hold on;
plot(t, Fx_d + Fx_p, 'r--', 'LineWidth', 1.0);
xline(t_peak, ':');
legend('F_{whole}', 'F_{dike}+F_{parapet}', 'Location','best'); grid on;
xlabel('Time (s)'); ylabel('Force (N/m)');
title('Whole vs (Dike + Parapet)');

figure('Color','w','Position',[100 470 820 280]);
plot(t, residual, 'k-', 'LineWidth', 1.0); hold on;
yline(0,'k:'); yline(tol_abs,'--'); yline(-tol_abs,'--');
xlabel('Time (s)'); ylabel('Residual (N/m)'); grid on;
title('Additivity residual: F_{whole} - (F_{dike}+F_{parapet})');

%% ==================== Local functions ====================
function [time, Fx] = local_read_force_csv(fn)
    % Detect options and preserve headers if possible
    opts = detectImportOptions(fn, 'Delimiter',';');
    try
        opts.VariableNamingRule = 'preserve';
    catch
        % Older MATLAB: headers may be sanitised automatically
    end
    T = readtable(fn, opts);

    % Display the detected names (useful when debugging)
    % disp(T.Properties.VariableNames.');

    % Normaliser: lower-case, replace non-alnum with single spaces
    norm = @(s) regexprep(lower(regexprep(s, '[^a-zA-Z0-9]+', ' ')), '\s+', ' ');

    names = T.Properties.VariableNames;
    nn    = cellfun(norm, names, 'uni', 0);

    % Find time column
    itime = find(contains(nn, 'time'), 1, 'first');
    if isempty(itime)
        error('Could not find a "Time" column in %s', fn);
    end

    % Find force-x column robustly
    candidates = {'forcefluid x', 'force x', 'forcefluidx', 'forcefluid x n m'};
    ifx = [];
    for k = 1:numel(candidates)
        ifx = find(contains(nn, candidates{k}), 1, 'first');
        if ~isempty(ifx), break; end
    end
    if isempty(ifx)
        % Fallback: first column that contains both 'force' and 'x'
        ifx = find(contains(nn, 'force') & contains(nn, 'x'), 1, 'first');
    end
    if isempty(ifx)
        error('Could not find a ForceFluid.x column in %s', fn);
    end

    % Extract as double
    time = double(T{:, itime});
    Fx   = double(T{:, ifx});
end

function [t2, F2] = local_apply_window(t, F, tmin, tmax)
    if isempty(tmin) && isempty(tmax)
        t2 = t; F2 = F; return;
    end
    mask = true(size(t));
    if ~isempty(tmin), mask = mask & (t >= tmin); end
    if ~isempty(tmax), mask = mask & (t <= tmax); end
    t2 = t(mask); F2 = F(mask);
end
