function z=aktivasiRBF(pusat,betas,input);
% untuk menghitung nilai aktivasi untuk semua neuron RBF, setiap neuron
% dis=deskripsikan dengan prtotypenya/contoh/ yaitu pusatnya
%parameter:
% pusat = matriks dari vektor pusatnya neuron, 1 per baris
% betas= vektor dari koefisien beta untuk neuron RBFnya
%input = vektor kolom yang berisi input

%=======================================================================

%mengurangkan input dari semua pusat
%diffs menjadi matriks k x n dimana k adalah jumlah pusat, dan n jumlah
%dimensi input
diffs=bsxfun(@minus,pusat,input);

%jumlahan dari jarak yg di kuadratkan (jarak L2 kuadrat)
%sqrdDists menjadi vektor k x 1 dimana k adalah jumlah pusat
sqrdDists=sum(diffs.^2,2);

%mengaplikasikan koefisien beta dan menghitung ekponen negatifnya
z=exp(-betas.*sqrdDists);
end

