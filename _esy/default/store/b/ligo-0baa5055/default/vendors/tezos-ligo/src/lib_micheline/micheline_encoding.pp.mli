Caml1999N029����   =         		;vendors/tezos-ligo/src/lib_micheline/micheline_encoding.mli����  �  s  �  Ġ����1ocaml.ppx.context��&_none_@@ �A����������)tool_name���*ppx_driver@@@����,include_dirs����"[]@@@����)load_path!����
%@%@@����,open_modules*����.@.@@����+for_package3����$None8@8@@����%debug=����%falseB@B@@����+use_threadsG����
K@K@@����-use_vmthreadsP����T@T@@����/recursive_typesY����]@]@@����)principalb����%f@f@@����3transparent_modulesk����.o@o@@����-unboxed_typest����7x@x@@����-unsafe_string}����@�@�@@����'cookies�����"::�����������,inline_tests�@�@@����(disabled��.<command-line>A@A�A@I@@��A@@�A@J@@@@�@@����������������,library-name�@�@@����/tezos_micheline��A@A�A@P@@��A@Q@@@@�@@�������@�@@@�@@�@@@�@@�@@@@�@@@�@�����Р.table_encoding��	;vendors/tezos-ligo/src/lib_micheline/micheline_encoding.mli]'+�]'9@���'variant����&string��^<F�^<L@@�@@@��@�����-Data_encoding(encoding��_PU�_Pk@���!l��!_PR�"_PT@@@@�	@@@��@�����-Data_encoding(encoding��.`ot�/`o�@���!p��5`oq�6`os@@@@�	@@@�����-Data_encoding(encoding��@a���Aa��@������)Micheline$node��Ka���La��@���!l��Ra���Sa��@@@���!p��Ya���Za��@@@@��\a��@@@@�@@@�*@@@�?@@@��a^<>!@@@@���)ocaml.doc.�������	� Encoding for expressions, as their {!canonical} encoding.
    Locations are stored in a side table.
    See {!canonical_encoding} for the [variant] parameter. ��oZ���p\�&@@@@@@@��r]''2@�3@���Р/erased_encoding��{g	�	��|g	�	�@���'variant����&string���h	�	���h	�	�@@�@@@��@��!l���i	�	���i	�	�@@@��@�����-Data_encoding(encoding���j	�	���j	�	�@���!p���j	�	���j	�	�@@@@�	@@@�����-Data_encoding(encoding���k	�
��k	�
'@������)Micheline$node���k	�
��k	�
@���!l���k	�	���k	�	�@@@���!p���k	�	���k	�
 @@@@���k	�	�@@@@�@@@�*@@@�>@@@���h	�	�!@@@@���n��������	� Encoding for expressions, as their {!canonical} encoding.
    Locations are erased when serialized, and restored to a provided
    default value when deserialized.
    See {!canonical_encoding} for the [variant] parameter. ���c����f	h	�@@@@@@@���g	�	�1@�2@���Р-node_encoding���m
)
-��m
)
:@�����-Data_encoding(encoding���m
)
S��m
)
i@������0Micheline_parser$node���m
)
=��m
)
R@@�@@@@�@@@@@��m
)
)@�@���Р;canonical_location_encoding��p
�
��p
�
�@�����-Data_encoding(encoding��q
�
��q
�
�@������)Micheline2canonical_location�� q
�
��!q
�
�@@�@@@@�@@@@���������	+ Encoding for canonical integer locations. ��0o
k
k�1o
k
�@@@@@@@��3p
�
�@�@���Р2canonical_encoding��<w �=w @���'variant����&string��Hx#�Ix)@@�@@@��@�����-Data_encoding(encoding��Uy-2�Vy-H@���!l��\y-/�]y-1@@@@�	@@@�����-Data_encoding(encoding��gzLe�hzL{@������)Micheline)canonical��rzLQ�szLd@���!l��yzLN�zzLP@@@@�	@@@@�@@@�"@@@��x@@@@���K�������
   Encoding for expressions in canonical form. The first parameter
    is a name used to produce named definitions in the schemas. Make
    sure to use different names if two expression variants with
    different primitive encodings are used in the same schema. ���s
�
���v��@@@@@@@���w  (@�)@���Р5canonical_encoding_v0���~����~��@���'variant����&string�������@@�@@@��@�����-Data_encoding(encoding��� @�� @,@���!l��� @�� @@@@@�	@@@�����-Data_encoding(encoding��� A0I�� A0_@������)Micheline)canonical��� A05�� A0H@���!l��� A02�� A04@@@@�	@@@@�@@@�"@@@�����@@@@���z��������	^ Old version of {!canonical_encoding} for backward compatibility.
    Do not use in new code. ���|}}��}��@@@@@@@���~��(@�)@���Р5canonical_encoding_v1��� E���� E��@���'variant����&string��  F��� F��@@�@@@��@�����-Data_encoding(encoding�� G��� G�@���!l�� G��� G��@@@@�	@@@�����-Data_encoding(encoding�� H-�  HC@������)Micheline)canonical��* H�+ H,@���!l��1 H�2 H@@@@�	@@@@�@@@�"@@@��7 F��@@@@�����������	^ Old version of {!canonical_encoding} for backward compatibility.
    Do not use in new code. ��D Caa�E D��@@@@@@@��G E��(@�)@���Р5canonical_encoding_v2��P Kmq�Q Km�@���'variant����&string��\ L���] L��@@�@@@��@�����-Data_encoding(encoding��i M���j M��@���!l��p M���q M��@@@@�	@@@�����-Data_encoding(encoding��{ N���| N��@������)Micheline)canonical��� N���� N��@���!l��� N���� N��@@@@�	@@@@�@@@�"@@@��� L��@@@@���2_�������	" Alias for {!canonical_encoding}. ��� JEE�� JEl@@@@@@@��� Kmm(@�)@@