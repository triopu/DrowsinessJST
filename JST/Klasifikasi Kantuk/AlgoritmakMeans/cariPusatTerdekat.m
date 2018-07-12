function anggota=cariPusatTerdekat(X,pusat)
%UNTITLED5 Summary of this function goes here
% dalam algortima k-means, titik data dimasukkan kedalam sebuah cluster 
%   Detailed explanation goes here berdasarkan jarak euclidean antara titik
%   data dan pusat cluster
%parameter :
% X = set data, 1 per baris
%pusat= pusat sekarang, 1 per baris

%anggota= vektor kolom berisi index pusat terdekat (1-k)
%==========================================================================

k=size(pusat,1); %jumlah pusat
m=size(X,1); %jumlah titik data

anggota=zeros(m,1); %anggotanya: jumlah cluster utk setiap contoh (pusat)
jarak=zeros(m,k); %membuat matriks yang berisi jarak antara titik data dan setiap pusat cluster

%untuk setiap cluster...
for i=1:k
    %menghitung jarak kuadrat rather than euclidean
    diffs=bsxfun(@minus,X,pusat(i,:)); %menghitung selisih pusat i dari semua titik data
    sqrdDiffs=diffs.^2 %dikuadratkan
    jarak(:,i)=sum(sqrdDiffs,2); %
end
%mencari jarak terdekat
[minVals anggota]=min(jarak,[],2);

end

