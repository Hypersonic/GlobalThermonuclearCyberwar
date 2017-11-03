%ifndef LAUNCHSITES_S
%define LAUNCHSITES_S
%include "countries.s"
%assign n_launchsites 0
; launchsite ptr_to_name, country_code, x, y
%macro launchsite 4
    dw %1 ; +0 ptr to launchsite name
    dw %2 ; +2 country_id
    dw %3 ; +4 x
    dw %4 ; +6 y
    %assign n_launchsites n_launchsites + 1
%endmacro


launchsites:
; us:
launchsite lgm30_321, COUNTRY_AMERICA, 70, 77
launchsite lgm30_351, COUNTRY_AMERICA, 73, 84
launchsite lgm30_91,  COUNTRY_AMERICA, 65, 75
launchsite lgm30_341, COUNTRY_AMERICA, 60, 79
; ussr:
launchsite tatishchevo, COUNTRY_USSR, 186, 74
launchsite tyumen, COUNTRY_USSR, 202, 68
launchsite olovyannaya, COUNTRY_USSR, 158, 76
launchsite zhangiz_tobe, COUNTRY_USSR, 215, 77
end_launchsites:

launchsite_names:
; us:
lgm30_321: db "321st Missile Wing LGM-30 Minuteman Missile Launch Sites", 0
lgm30_351: db "351st Missile Wing LGM-30 Minuteman Missile Launch Sites", 0
lgm30_91:  db "91st Missile Wing LGM-30 Minuteman Missile Launch Sites", 0
lgm30_341: db "341st Missile Wing LGM-30 Minuteman Missile Launch Sites", 0
; ussr:
tatishchevo:  db "Tatishchevo", 0
tyumen:       db "Tyumen", 0
olovyannaya:  db "Olovyannaya", 0
zhangiz_tobe: db "Zhangiz Tobe", 0
end_launchsite_names:



%endif
