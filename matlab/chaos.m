clear; clc; close all;

% 1. Parámetros reales extraídos de la Netlist
a = 10e3 / 20.6e3;   % ~ 0.4854
b = 10e3 / 19.61e3;  % ~ 0.5099
c = 10e3 / 20e3;     % 0.5
di = 10e3 / 100e3;   % 0.1

% 2. Constante de tiempo del circuito (Escalamiento)
R0 = 10e3;
C0 = 10e-9;
tau = R0 * C0;       % 0.1 ms (acelera el sistema matemático)

% 3. Función no lineal (Aproximación del OpAmp saturado)
% El OpAmp tiene una ganancia altísima (1M / 981 ohms ~ 1019)
% y se satura a +- 6.4V.
Vmax = 6.4;
ganancia = 1e6 / 981; 
f = @(x) Vmax * tanh(ganancia * x / Vmax);

% 4. Tiempo de simulación y opciones
% Simulamos 0.5 segundos (500 ms) igual que en el comando .tran de TopSpice
tspan = [0 0.5];
opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-10);

% Condiciones iniciales sacadas de los comandos 'ic' de la Netlist
% C3 (x) = 0.35V, C2 (y) = 0.25V, C1 (z) = 0.1V
x0 = [0.35; 0.25; 0.1];

% 5. Ecuaciones del sistema ESCALADAS EN EL TIEMPO
% Dividir todo entre 'tau' convierte el tiempo matemático a segundos reales
sys = @(t, X) [
    X(2) / tau;
    X(3) / tau;
    (-a*X(1) - b*X(2) - c*X(3) + di * f(X(1))) / tau
];

% 6. Resolver el sistema
[t, sol] = ode45(sys, tspan, x0, opts);
x = sol(:,1);
y = sol(:,2);

% Quitar el transitorio inicial (los primeros 20 ms)
idx = t > 0.02;
t_plot = t(idx);
x_plot = x(idx);
y_plot = y(idx);

% --- GRAFICAR RESULTADOS ---
figure('Name', 'Oscilador Lu Chen - Modelo del Circuito Real', 'Color', 'w');

% Gráfica en el tiempo
subplot(2,1,1);
plot(t_plot, x_plot, 'b', t_plot, y_plot, 'g', 'LineWidth', 1);
title(sprintf('Respuesta en el tiempo (a=%.3f, b=%.3f, c=%.1f, di=%.1f)', a, b, c, di));
xlabel('Tiempo (s)'); ylabel('Voltaje (V)');
legend('x(t)', 'y(t)');
grid on;

% Retrato de fase (x vs y) - El Atractor
subplot(2,1,2);
plot(x_plot, y_plot, 'b', 'LineWidth', 0.5);
title('Retrato de Fase (Atractor) - Vista X-Y');
xlabel('x(t) [V]'); ylabel('y(t) [V]');
axis equal tight;
grid on;