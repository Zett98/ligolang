Caml1999N029����   0         	.vendors/tezos-ligo/src/lib_stdlib/tzString.mli����  �  �  �  �����1ocaml.ppx.context��&_none_@@ �A����������)tool_name���*ppx_driver@@@����,include_dirs����"[]@@@����)load_path!����
%@%@@����,open_modules*����.@.@@����+for_package3����$None8@8@@����%debug=����%falseB@B@@����+use_threadsG����
K@K@@����-use_vmthreadsP����T@T@@����/recursive_typesY����]@]@@����)principalb����%f@f@@����3transparent_modulesk����.o@o@@����-unboxed_typest����7x@x@@����-unsafe_string}����@�@�@@����'cookies�����"::�����������,inline_tests�@�@@����(disabled��.<command-line>A@A�A@I@@��A@@�A@J@@@@�@@����������������,library-name�@�@@����,tezos_stdlib��A@A�A@M@@��A@N@@@@�@@�������@�@@@�@@�@@@�@@�@@@@�@@@�@��������#Set��	.vendors/tezos-ligo/src/lib_stdlib/tzString.mliZ���Z��@�������#Set!S��Z���Z��@�@@����#elt��Z���Z��@    �@@@A�����&string��!Z���"Z��@@�@@@@��%Z��@@�@@@��(Z��@�@������#Map��2\���3\��@�������#Map!S��>\���?\��@�@@����#key��G\���H\��@    �@@@A�����&string��R\���S\��@@�@@@@��V\��@@�@@@��Y\��@�@���Р*split_path��b`RV�c`R`@��@����&string��l`Rc�m`Ri@@�@@@����$list��u`Rt�v`Rx@�����&string��~`Rm�`Rs@@�@@@@�@@@�@@@@���)ocaml.docP�������	u Splits a string on slashes, grouping multiple slashes, and
    ignoring slashes at the beginning and end of string. ���^����_Q@@@@@@@���`RR@�@���Р%split���j
I
M��j
I
R@��@����$char���j
I
U��j
I
Y@@�@@@���#dup����$bool���j
I
b��j
I
f@@�@@@���%limit����#int���j
I
q��j
I
t@@�@@@��@����&string���j
I
x��j
I
~@@�@@@����$list���j
I
���j
I
�@�����&string���j
I
���j
I
�@@�@@@@�@@@�@@@���j
I
j@@@���j
I
]@@@�A@@@@���d��������
  � Splits a string on a delimiter character. If [dup] is set to [true],
    groups multiple delimiters and strips delimiters at the
    beginning and end of string. If [limit] is passed, stops after [limit]
    split(s). [dups] defaults to [true] and [limit] defaults to [max_int].
    Examples:
    - split ~dup:true ',' ",hello,,world,"] returns ["hello"; "world"]
    - split ~dup:false ',' ",,hello,,,world,,"] returns [""; "hello"; ""; ""; "world"; ""]
 ���bzz��i
E
H@@@@@@@���j
I
I"@�#@���Р*has_prefix���m
�
�� m
�
�@���&prefix����&string��m
�
��m
�
�@@�@@@��@����&string��m
�
��m
�
�@@�@@@����$bool��m
�
�� m
�
�@@�@@@�@@@��$m
�
�@@@@����񐠠����< [true] if input has prefix ��1l
�
��2l
�
�@@@@@@@��4m
�
�@�@���Р-remove_prefix��=p26�>p2C@���&prefix����&string��Ip2M�Jp2S@@�@@@��@����&string��Tp2W�Up2]@@�@@@����&option��]p2h�^p2n@�����&string��fp2a�gp2g@@�@@@@�@@@�@@@��lp2F@@@@����9�������	I Some (input with [prefix] removed), if string has [prefix], else [None] ��yo
�
��zo
�1@@@@@@@��|p22@� @���Р-common_prefix���s����s��@��@����&string���s����s��@@�@@@��@����&string���s����s��@@�@@@����#int���s����s��@@�@@@�@@@�@@@@���%t�������	* Length of common prefix of input strings ���rpp��rp�@@@@@@@���s��@�@���Р(mem_char���v	��v@��@����&string���v��v@@�@@@��@����$char���v��v"@@�@@@����$bool���v&��v*@@�@@@�@@@�@@@@���`��������	2 Test whether a string contains a given character ���u����u�@@@@@@@���v@�@���Р)fold_left���y{��y{�@��@��@��!a��y{��y{�@@@��@����$char��y{��y{�@@�@@@��!a��y{��y{�@@@�
@@@�@@@��@��!a�� y{��!y{�@@@��@����&string��*y{��+y{�@@�@@@��!a��1y{��2y{�@@@�
@@@�@@@��6y{�@@@@�����������	I Functional iteration over the characters of a string from first to last ��Cx,,�Dx,z@@@@@@@��Fy{{@�@���Р&is_hex��O|���P|��@��@����&string��Y|���Z|�@@�@@@����$bool��b|��c|�
@@�@@@�@@@@����2�������	4 Test whether a string is a valid hexadecimal value ��r{���s{��@@@@@@@��u|��@�@���Р,pp_bytes_hex��~=A�=M@��@�����&Format)formatter���=P��=`@@�@@@��@����%bytes���=d��=i@@�@@@����$unit���=m��=q@@�@@@�@@@�@@@@��� o�������	+ Pretty print bytes as hexadecimal string. ���~��~<@@@@@@@���==@�@@