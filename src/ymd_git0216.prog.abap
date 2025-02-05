*&---------------------------------------------------------------------*
*& Report ymd_git0216
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0216.

TYPES: BEGIN OF ty_tab,
         id    TYPE char4,
         value TYPE char10,
       END OF ty_tab.

TYPES tty_tab TYPE STANDARD TABLE OF ty_tab WITH NON-UNIQUE KEY id.

DATA gt_tab1 TYPE tty_tab.
DATA gt_tab2 TYPE tty_tab.
DATA gt_tab3 TYPE tty_tab.

gt_tab1 = VALUE #( ( id = '0001' value = 'AAAA' )
                   ( id = '0002' value = 'AABB' )
                   ( id = '0003' value = 'AACC' )
                   ( id = '0004' value = 'AADD' )
                   ( id = '0005' value = 'AAEE' ) ).

gt_tab2 = VALUE #( ( id = '0002' value = 'BBBB' )
                   ( id = '0004' value = 'BBDD' ) ).

SELECT tab1~id
INTO TABLE @gt_tab3
FROM
ztab1_test AS tab1
LEFT JOIN
ztab2_test AS tab2
 ON tab1~id EQ tab2~id
WHERE tab2~id IS NULL.

LOOP AT gt_tab3
INTO DATA(gs_tab3).

  WRITE:/5 gs_tab3-id, gs_tab3-value.

ENDLOOP.
