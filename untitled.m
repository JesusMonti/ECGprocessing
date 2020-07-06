function varargout = untitled(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before untitled is made visible.
function untitled_OpeningFcn(hObject, eventdata, handles, varargin)
% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = untitled_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function senial_Callback(hObject, eventdata, handles)
% hObject    handle to senial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of senial as text
%        str2double(get(hObject,'String')) returns contents of senial as a double
texto=get(hObject,'String');%Almacena valor ingresado
handles.senial=texto;%Almacena el identificador
guidata(hObject,handles);%Salva los datos de la aplicacion

% --- Executes during object creation, after setting all properties.
function senial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to senial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in iniciar.
function iniciar_Callback(hObject, eventdata, handles)
% hObject    handle to iniciar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global X Y muestras
texto=handles.senial;
% En esta fucnión es leido el titulo de la señal a procesar, y se
% transforma en un archivo excel para poder ser leido ademas de elegir la
% ubicacion exacta de la señal.
X=xlsread(texto+".csv","A1:GR1");
Y=xlsread(texto+".csv","A2:GR2");
axes(handles.grafico1);
plot(X,Y);
%Se grafica la señal en el primer plot
title('ECG señal');
xlabel('Tiempo (t)');
ylabel('Amplitud (mV)');



% --- Executes on button press in calcular.
function calcular_Callback(hObject, eventdata, handles)
% hObject    handle to calcular (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global X Y muestras
% Se determina la frecuencia de cardiaca de la señal previamente leída, y
% se determina en base a la frecuencia se presenta alguna enfermedad entre
% bradicardia(frecuencia baja), taquicardia(frecuencia alta) o si su ritmo es normal.
maximos=[];
maximos_posicion=[];
vector_Periodo=[];
for i=2:length(Y)-1
    if Y(i)>Y(i-1) && Y(i)>Y(i+1) && Y(i)>2
       maximos(end+1)=Y(i);
       maximos_posicion(end+1)=X(i);
    end
end
for i=1:length(maximos_posicion)-1
    vector_Periodo(i)=maximos_posicion(i+1)-maximos_posicion(i);
end
maximos_posicion;
global PC FC ts fs
PC=mean(vector_Periodo);
FC=60/PC;
set(handles.frecuencia,'String',FC+" lpm")
if FC>60 && FC<90
    set(handles.diagnostico,'String',"Ritmo normal")
end
if FC<60
    set(handles.diagnostico,'String',"Bradicardia")
end
if FC >90
    set(handles.diagnostico,'String',"Taquicardia")
end
%Se calcula el espectro de la señal ECG por medio de la transformada de
%fourier y se muestra en los siguiente graficos 2 y 3 del GUI.
muestras=length(X);
fs=2*FC;
ts=1/fs;
t=0:fs/muestras:fs-fs/muestras;
axes(handles.grafico2);
plot(t,abs(fft(Y)))
n_fft=length(Y);
f_shift=(-n_fft/2:n_fft/2-1)*(fs/n_fft);
y_fourier=fftshift(fft(Y));

axes(handles.grafico2);
plot(f_shift,abs(y_fourier))
title('ECG espectro');
xlabel('Frecuencias (Hz)');
ylabel('Amplitud (mV)');

y_fourier=fftshift(fft(Y))-100;
axes(handles.grafico3);
plot(f_shift,abs(y_fourier))
title('ECG espectro exagerado');
xlabel('Frecuencias (Hz)');
ylabel('Amplitud (mV)');

% --- Executes on button press in qrs.
function qrs_Callback(hObject, eventdata, handles)
% hObject    handle to qrs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global X Y
% Calcula el tiempo del intervalo QRS,dado que el intervalo de este puede
% indicarlos diferentes patolgia.
r=[];
s=[];
rd=[];
sd=[];
vector_rs=[];
maximos_posicion=[];

for i=2:length(Y)-1
    if Y(i)>Y(i-1) && Y(i)>Y(i+1) && Y(i)>2
       maximos_posicion(end+1)=X(i);
    end
end

for j=2:length(Y)-1
   if Y(j)-Y(j-1)>0.04 && Y(j)-Y(j+1)>-0.04 && Y(j)-Y(j+1)<0.04 && Y(j)>0.85 && Y(j)<0.95  
      r(end+1)=X(j);
   end
   if Y(j)-Y(j-1)>-0.04 && Y(j)-Y(j-1)<0.04 && Y(j+1)-Y(j)>0.04 && Y(j)>0.85 && Y(j)<0.95
      s(end+1)=X(j);
   end
end

for i=1:length(maximos_posicion)
    for j=1:length(s)-1
        if maximos_posicion(i)-s(j)<0.15 && maximos_posicion(i)-s(j)>0
            %if maximos_posicion(i)-s(j)<0
            sd(end+1)=s(j);
           % end
        end
        
    end
end

for i=1:length(maximos_posicion)
    for j=1:length(r)
        if r(j)-maximos_posicion(i)<0.3 && r(j)-maximos_posicion(i)>0
            %if maximos_posicion(i)-s(j)<0
            rd(end+1)=r(j);
           % end
        end
        
    end
end

for i=1:length(rd)
    vector_rs(i)=rd(i)-sd(i);
end

vector_rs

RS=mean(vector_rs);
set(handles.t1,'String',RS*1000+" ms")

% --- Executes on button press in pq.
function pq_Callback(hObject, eventdata, handles)
% hObject    handle to pq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global X Y
% Calcula el tiempo del intervalo PQ,dado que el intervalo de este puede
% indicarlos diferentes patolgia.
valor=[];
p=[];
q=[];
vector_pq=[];

for j=2:length(Y)-1
   if Y(j-1)-Y(j)>0.04 && Y(j)-Y(j+1)>-0.04 && Y(j)-Y(j+1)<0.04 && Y(j)>0.85 && Y(j)<0.92
      p(end+1)=X(j);
   end
   if Y(j)-Y(j-1)>-0.04 && Y(j)-Y(j-1)<0.04 && Y(j+1)-Y(j)>0.04 && Y(j)>0.85 && Y(j)<0.92
      q(end+1)=X(j);
   end
end

for i=1:length(p)
    for j=1:length(q)
        if q(j)-p(i)<0.1 && q(j)-p(i)>0
            vector_pq(end+1)=q(j)-p(i);
        end
    end
end

vector_pq;

PQ=mean(vector_pq);
set(handles.t2,'String',PQ*1000+" ms")

% --- Executes on button press in st.
function st_Callback(hObject, eventdata, handles)
% hObject    handle to st (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global X Y
% Calcula el tiempo del intervalo ST,dado que el intervalo de este puede
% indicarlos diferentes patolgia.
valor=[];
s=[];
t=[];
vector_st=[];

for j=2:length(Y)-1
   if Y(j)-Y(j-1)>0.04 && Y(j)-Y(j+1)>-0.04 && Y(j)-Y(j+1)<0.04 && Y(j)>0.85 && Y(j)<0.95
      s(end+1)=X(j);
   end
   if Y(j)-Y(j-1)>-0.04 && Y(j)-Y(j-1)<0.04 && Y(j+1)-Y(j)>0.04 && Y(j)>0.85 && Y(j)<0.95
      t(end+1)=X(j);
   end
end

for i=1:length(s)
    for j=1:length(t)
        if t(j)-s(i)<0.1 && t(j)-s(i)>0
            vector_st(end+1)=t(j)-s(i);
        end
    end
end

ST=mean(vector_st);
set(handles.t3,'String',ST*1000+" ms")

% --- Executes on button press in tp.
function tp_Callback(hObject, eventdata, handles)
% hObject    handle to tp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
