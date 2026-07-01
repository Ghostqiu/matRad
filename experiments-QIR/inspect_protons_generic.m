% inspect_protons_generic.m  —  load the matRad proton base-data ("Generic" machine) and show it.
% Run in MATLAB:  >> inspect_protons_generic
% No matRad needed (just loads the .mat). Shows meta, the energy menu, one energy's depth profile,
% and plots Bragg curves (Z=idd) + lateral sigma vs depth.

set(0, 'DefaultFigureVisible', 'on');   % in case matRad disabled figures earlier in the session
MAT = 'C:\Users\qiuyu\Documents\matrad-project\matRad\matRad\basedata\protons_generic_TOPAS.mat';
S = load(MAT); machine = S.machine; data = machine.data;
nE = numel(data);

%% --- (A) machine-level meta ---
fprintf('\n===== machine.meta =====\n');
m = machine.meta;
flds = {'name','radiationMode','dataType','SAD','BAMStoIsoDist','description'};
for i = 1:numel(flds)
    if isfield(m, flds{i})
        v = m.(flds{i});
        if ischar(v), fprintf('  %-14s : %s\n', flds{i}, v);
        else,         fprintf('  %-14s : %g\n', flds{i}, v); end
    end
end
energies = arrayfun(@(d) d.energy, data);
fprintf('  #energy layers : %d   (%.1f - %.1f MeV)\n', nE, min(energies), max(energies));
fprintf('  per-energy fields: %s\n', strjoin(fieldnames(data), ', '));

%% --- (B) energy menu (sample 8 of the layers) ---
fprintf('\n===== energy layers (8 sampled) =====\n');
fprintf('  %4s %8s %9s %8s %9s %7s\n', '#', 'E(MeV)', 'range', 'peakPos', 'maxDepth', '#depth');
idx = round(linspace(1, nE, 8));
for k = idx
    d = data(k); dep = d.depths(:);
    rng = getfieldsafe(d,'range',NaN); pk = getfieldsafe(d,'peakPos',NaN);
    fprintf('  %4d %8.1f %9.1f %8.1f %9.1f %7d\n', k, d.energy, rng, pk, max(dep), numel(dep));
end

%% --- (C) one energy's depth profile (~150 MeV), 6 sampled depths ---
[~, ei] = min(abs(energies - 150)); d = data(ei); dep = d.depths(:);
fprintf('\n===== depth profile for E = %.1f MeV (6 of %d depths) =====\n', d.energy, numel(dep));
fprintf('  %9s %9s %9s', 'depth(mm)', 'Z=idd', 'sigma');
hasDouble = isfield(d,'sigma1');
if hasDouble, fprintf(' %7s %7s %6s', 'sigma1','sigma2','w'); end
fprintf('\n');
j6 = round(linspace(1, numel(dep), 6));
for j = j6
    fprintf('  %9.1f %9.4f %9.2f', dep(j), col(d.Z,j), col(d.sigma,j));
    if hasDouble, fprintf(' %7.2f %7.2f %6.3f', col(d.sigma1,j), col(d.sigma2,j), col(d.weight,j)); end
    fprintf('\n');
end

%% --- (D) plots: Bragg curves (Z) + lateral sigma vs depth, for a few energies ---
figure('Name','protons_Generic','Position',[100 100 1100 420],'Visible','on');
sel = round(linspace(1, nE, 5));            % 5 energies across the menu
subplot(1,2,1); hold on; grid on;
for k = sel, plot(data(k).depths, data(k).Z, 'DisplayName', sprintf('%.0f MeV', data(k).energy)); end
xlabel('depth (mm)'); ylabel('Z = integrated depth dose (idd)'); title('Bragg curves'); legend('show','Location','northwest');
subplot(1,2,2); hold on; grid on;
for k = sel, plot(data(k).depths, data(k).sigma, 'DisplayName', sprintf('%.0f MeV', data(k).energy)); end
xlabel('depth (mm)'); ylabel('lateral \sigma (mm)'); title('lateral spread vs depth (single-Gauss)'); legend('show','Location','northwest');
drawnow;   % force the window to render now (so it appears immediately in the GUI)
fprintf('\n(plotted Bragg curves + sigma for 5 energies)\n');

% ---- helpers ----
function v = getfieldsafe(s, f, def), if isfield(s,f), v = s.(f); else, v = def; end, end
function x = col(a, j), a = a(:); x = a(min(j, numel(a))); end   % robust index (scalar/vector Z/sigma)
