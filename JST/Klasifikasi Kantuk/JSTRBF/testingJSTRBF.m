function z = testingJSTRBF(pusat, betas, Theta, input)
%untuk menghitung output dari JST RBF untuk masukan yang tersedia
%fungsi ini menghitung nilai aktivasi dari semua neuron RBF dilapisan
%tersembunyi meggunakan pusat dan betas yang tersedia, kemudian menghitugn
%nilai lapisan output jaringan menggunakan koef. Theta

%parameter
%pusat = vektor yang dipilih sebagai contoh / prototypes
%betas = koefisien beta untuk contoh / prototypes tersebut
%Theta = bobot keluaran yang diaplikasikan ke neuron aktivasi
%input = vektor input untuk men-testing JST RBF secara keseluruhan

%=========================================================================

phis=aktivasiRBF(pusat, betas, input); %menghitung aktivasi neuron RBF utk 'input' ini
phis=[1;phis]; %menambahkan 1 di awal vektor aktivasi

%mengkalikan fungsi aktiviasi dengan bobot dan mengambil jumlahannya,
%dilakukan untuk masing masing tingkat kantuk. hasilnya adalah vektor kolom
%dengan 1 baris per nodus output

%Theta = pusat x tingkat theta'=tingkat x pusat
%phis = pusat x 1
% z = Theta' *phis= tingkat x 1
z= Theta'*phis;

end

