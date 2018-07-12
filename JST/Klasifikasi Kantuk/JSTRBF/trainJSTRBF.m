function [pusat, betas ,Theta] = trainJSTRBF(trainX, targetY, PusatPerTingkat, verbose)
% parameter inputnya:
% trainX = vektor yang ditraining , 1 per baris
% targetY= nilai target tingkat kantuk dengan input
% PusatPerTingkat = jumlah pusat per tingkat kantuk yang dipilih atau akan dicari 
% verbose = diprint atau tidak (true/false)

%dalam training JST ada 3 proses
%1. pemilihan pusat dengan algortima k-Means clustering
%2. penghitungan koefisien beta (yang mengontrol lebar fungsi radial sebagai fungsi aktivasi neuron jst rbf).
%3. training bobot keluaran untuk setiap kategori dengan gradient descent

%==========================================================================

jmltgkt=size(unique(targetY),1);  %jumlah tingkat kantuk
m=size(trainX,1);                 %jumlah data input

% pemilihan pusat RBF dan parameter :
% menggunakan algoritma k-means, data dikelompokkan per tingkat,
%kemudian dikelompokkan lagi per cluster terpisah

if(verbose)
    disp('1.1 Pemilihan pusat dengan algortima k-means');
end

pusat= [];
betas= [];

%untuk setiap tingkat kantuk:
for c=1:jmltgkt
    if(verbose)
        fprintf('pusat tingkat kantuk %d ... \n',c);
        if exist('versi octave') fflush(stdout); end;
    end
    
%pilih input untuk tingkat 'c'
Xc=trainX((targetY==c),:);

%mengambil sejumlah 'pusatPerTingkat' pertama dari data tsb sebagai pusat
%awal
pusat_awal=Xc(1:PusatPerTingkat,:);

%menjalankan algoritma k-meand dengan iterasi maksimal 100
[pusat_c,anggota_c]= kMeans(Xc,pusat_awal,100);
%menghilangkan cluster kosong
utkhapus=[];

%untuk setiap pusat
for i=1:size(pusat_c,1)
    if (sum(anggota_c==i)==0)
        utkhapus = [utkhapus;i]; %jika ada pusat yang tidak punya anggota, hapus
    end
end

if(~isempty(utkhapus))
    %hapus pusat dari cluster kosong
    pusat_c(utkhapus,:)=[];
    %anggota baru(nilai index akan berubah)
    anggota_c=cariPusatTerdekat(Xc,pusat_c);
    
end


%2. Menghitung Koef. Beta yang mengatur lebar fungsi
if(verbose)
    disp('1.1.2 Menghitung Koef. Beta (lebar fungsi aktivasi)...')
    fprintf(' tingkat kantu %d betas ... \n',c);
    if exist('OCTAVE VERSION') fflush(stdout);end;
end
%menghitung beta utk semua cluster
betas_c=menghitungBetaRBF(Xc,pusat_c,anggota_c);
%meambahkan pusat dan nilai betanya ke jaringan
pusat=[pusat;pusat_c];
betas=[betas;betas_c];
end
jmlNeuronRBF=size(pusat,1);

%3.training bobot keluaran
%3.menghitung fungsi aktivasi RB pada set data training
if(verbose)
    disp('2. Menghitung neuron fungsi aktivasi RB pada full set data training')
end
%pertama, menghitung neuron aktivasi RB untuk full set data training
%X_activ menyimpan nilai aktivasi untuk setiap training set, 1 baris per
%data training dan 1 kolo per neuron
X_activ = zeros(m,jmlNeuronRBF);

%untuk setiap data training
for i=1:m
    input=trainX(i,:);
    %mendapatkan fungsi aktivasi untuk semua neuron RBF untuk input ini
    z=aktivasiRBF(pusat,betas,input);
    %menyimpan nilai aktivasi 'z'utk data training 'i'
    X_activ(i,:)=z';
end

%menambahkan kolom utk suku bias
X_activ =[ones(m,1), X_activ];

%tahap pembelajaran bobot keluaran
if (verbose)
    disp('3. Tahap Pembelajaran (learning) Bobot keluaran.')
end

%membuat matriks utk memuat semua bobot keluaran
%1 kolom per tingkat kantuk / output neuron
Theta = zeros(jmlNeuronRBF+1,jmltgkt);

%untuk setiap tingkat kantuk
for c=1:jmltgkt
    %membuat nilai y menjadi biner 1 untuk tingkat kantuk c dan 0 untuk
    %lainnya
    y_c=(targetY==c);
    %memakai persamaan untuk theta yg optimal
    Theta(:,c)=pinv(X_activ'*X_activ)*X_activ'*y_c;
end
end