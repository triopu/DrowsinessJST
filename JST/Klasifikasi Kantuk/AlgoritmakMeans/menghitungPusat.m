function pusat=menghitungPusat(X,pusatsebelumnya,anggota,k);
%UNTITLED6 Summary of this function goes here
%untuk menghitung pusat baru dg menhitung rata2 dari titik data
%pusat=menghitungPusat(X,pusat,anggota,k);
% parameternya
% X = set datanya, 1 per baris
% anggota = index pusatnya yg koresponding dg data di X (nilaninya dari
% 1-k)
%k = jumlah cluster
%keluarannya = matriks pusat dg baris k dimana setiap baris berisi  pusat
%=========================================================================
[m n]=size(X); %X berisi data se
pusat=zeros(k,n);

%untuk setiap pusat
for i=1:k
    %jika tidak ada titik termasuk sat, jangan mengubahnya
    if(~any(anggota==i))
        pusat(i,:)=pusatsebelumnya(i,:);
    %sebaliknya, jika ada, hitung pusat baru dari cluter tsb
    else
    points=X((anggota==i),:);
    pusat(i,:)=mean(points);
    end
end
end

