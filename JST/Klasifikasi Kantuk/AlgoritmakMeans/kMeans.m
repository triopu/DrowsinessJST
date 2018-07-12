function [ pusat,anggota ]=kMeans(X,pusat_awalnya,max_iter)
%UNTITLED4 Summary of this function goes here
%parameternya=
% X     = data input algoritma kmeans
% pusat_awalnya= pusat awal yang digunakan, 1 perbaris 
% max_iter= jumlah iterasi maksimal
%
% keluarannya 
% pusat= matriks k x n dari pusat yang awal, dengan n dimensi data di X
% anggota= vektor kolom berisi indeks cluster untuk masing2 X
%   Detailed explanation goes here

%=========================================================================
%jumlah pusat awal
k=size(pusat_awalnya,1);

pusat = pusat_awalnya;
prevpusat=pusat;

%algoritma k-means
for i=1:max_iter
    anggota=cariPusatTerdekat(X, pusat); %untuk setiap data di X, cari pusat terdekatnya
    pusat=menghitungPusat(X,pusat,anggota,k);%anggota diketahui, menhitung pusat baru
    
    %mengecek konvergensinya, jika pusat tidak berubah atau sampai iterasi
    %terakhir, telah konvergen
    if(prevpusat == pusat)
        break
    end
    prevpusat = pusat;
end
end

