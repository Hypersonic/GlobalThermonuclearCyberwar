%ifndef LAUNCHSITES_S
%define LAUNCHSITES_S

%include "countries.s"

%assign n_launchsites 0
; launchsite name, country_code, x, y
%macro launchsite 4
    db %2 ; country_id
    dw %3 ; x
    db %4 ; y (1 byte because 0-200)
    %assign n_launchsites n_launchsites + 1
%endmacro


launchsites:
launchsite "321st Missile Wing LGM-30 Minuteman Missile Launch Sites", COUNTRY_AMERICA, 70, 77
launchsite "351st Missile Wing LGM-30 Minuteman Missile Launch Sites", COUNTRY_AMERICA, 73, 84
launchsite "91st Missile Wing LGM-30 Minuteman Missile Launch Sites", COUNTRY_AMERICA, 65, 75
launchsite "341st Missile Wing LGM-30 Minuteman Missile Launch Sites", COUNTRY_AMERICA, 60, 79
;launchsite "Aleysk", COUNTRY_USSR, 235, 52
;launchsite "Perm", COUNTRY_USSR, 189, 57
;launchsite "Imeni Gastello", COUNTRY_USSR, 207, 51
;launchsite "Dombarovskiy", COUNTRY_USSR, 194, 50
;launchsite "Drovyanaya", COUNTRY_USSR, 109, 51
;launchsite "Irkutsk", COUNTRY_USSR, 107, 52
;launchsite "Itatka", COUNTRY_USSR, 241, 56
;launchsite "Kansk", COUNTRY_USSR, 258, 56
;launchsite "Kartaly", COUNTRY_USSR, 191, 53
;launchsite "Derazhnya", COUNTRY_USSR, 138, 49
;launchsite "Kostroma", COUNTRY_USSR, 161, 57
;launchsite "Kozelsk", COUNTRY_USSR, 152, 54
;launchsite "Gladkaya", COUNTRY_USSR, 253, 56
;launchsite "Lida", COUNTRY_USSR, 134, 53
;launchsite "Mozyr", COUNTRY_USSR, 141, 52
;launchsite "Verkhnyaya Salda", COUNTRY_USSR, 196, 58
;launchsite "Novosibirsk", COUNTRY_USSR, 237, 55
;launchsite "Omsk", COUNTRY_USSR, 219, 55
;launchsite "Pervomaysk", COUNTRY_USSR, 148, 46
;launchsite "Shadrinsk", COUNTRY_USSR, 202, 56
;launchsite "Svobodny", COUNTRY_USSR, 111, 51
launchsite "Tatishchevo", COUNTRY_USSR, 186, 74
;launchsite "Teykovo", COUNTRY_USSR, 180, 68
launchsite "Tyumen", COUNTRY_USSR, 202, 68
;launchsite "Uzhur", COUNTRY_USSR, 222, 68
;launchsite "Yedrovo", COUNTRY_USSR, 177, 65
launchsite "Olovyannaya", COUNTRY_USSR, 158, 76
;launchsite "Yoshkar Ola", COUNTRY_USSR, 191, 67
;launchsite "Yurya", COUNTRY_USSR, 187, 65
launchsite "Zhangiz Tobe", COUNTRY_USSR, 215, 77




%endif
