function betas = menghitungBetaRBF(X,pusat,anggota);
%untuk menghitung koefisien beta (lebar fungsi aktivasi JST)
   
%parameternya
% X = matriks semua sampel utk training JST, 1 per baris
% pusat = matriks dari pusat cluster, 1 per baris
% anggota = vektoe dari anggota cluster dari setia data di X. anggota itu :
% index baris dari pusat

%=========================================================================

jmlneuronRBF=size(pusat,1);
sigmas=zeros(jmlneuronRBF,1); %Menghitung sigma masing masing cluster

%untuk setiap cluster
for i=1:jmlneuronRBF
    pusatCluster=pusat(i,:); %memilih pusat cluster selanjutnya
    anggotanya=X((anggota==i),:);%select all anggota dari cluster tsb
    %menghitung rata rata jarak L2 ke semua anggota
    %selisih vektor 'pusat' dari setiap anggota vektor
    selisih=bsxfun(@minus,anggotanya,pusatCluster);
    selisihsqrd=sum(selisih.^2,2);
    jarak=sqrt(selisihsqrd);%akarnya utk mendapatkan jarak euclidean
    sigmas(i,:)=mean(jarak);%menghitung jarak ratarata, sebagai sigma 
end
%memastika tidak ada sigma yg nol
if(any(sigmas==0))
    error('salah satu sigma bernilai 0');
end
%menghitung nilai beta dari sigma
betas=1./(2.*sigmas.^2);
end

