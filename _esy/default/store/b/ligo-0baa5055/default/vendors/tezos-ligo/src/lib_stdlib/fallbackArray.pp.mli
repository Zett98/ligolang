Caml1999N029����   5         	3vendors/tezos-ligo/src/lib_stdlib/fallbackArray.mli����  &  �    �����1ocaml.ppx.context��&_none_@@ �A����������)tool_name���*ppx_driver@@@����,include_dirs����"[]@@@����)load_path!����
%@%@@����,open_modules*����.@.@@����+for_package3����$None8@8@@����%debug=����%falseB@B@@����+use_threadsG����
K@K@@����-use_vmthreadsP����T@T@@����/recursive_typesY����]@]@@����)principalb����%f@f@@����3transparent_modulesk����.o@o@@����-unboxed_typest����7x@x@@����-unsafe_string}����@�@�@@����'cookies�����"::�����������,inline_tests�@�@@����(disabled��.<command-line>A@A�A@I@@��A@@�A@J@@@@�@@����������������,library-name�@�@@����,tezos_stdlib��A@A�A@M@@��A@N@@@@�@@�������@�@@@�@@�@@@�@@�@@@@�@@@�@�������*ocaml.textǐ������	�

   This module implements arrays equipped with accessors that cannot
   raise exceptions. Reading out of the bounds of the arrays return a
   fallback value fixed at array construction time, writing out of the
   bounds of the arrays is ignored.

��	3vendors/tezos-ligo/src/lib_stdlib/fallbackArray.mliZ���a}@@@@@@���A�    �!t��d���d��@����!a��d���d��@@@�BA@@@A@���)ocaml.docꐠ�����	4 The type for array containing values of type ['a]. ��#c���$c��@@@@@@@��&d��@@�@���Р$make��/h	@	D�0h	@	H@��@����#int��9h	@	K�:h	@	N@@�@@@��@��!a��Bh	@	R�Ch	@	T@@@����!t��Jh	@	[�Kh	@	\@���!a��Qh	@	X�Rh	@	Z@@@@�	@@@�
@@@�@@@@���@)�������	t [make len v] builds an array [a] initialized [len] cells with
   [v]. The value [v] is the fallback value for [a]. ��bf���cg		?@@@@@@@��eh	@	@@�@���Р(fallback��nk	�	��ok	�	�@��@����!t��xk	�	��yk	�	�@���!a��k	�	���k	�	�@@@@�	@@@��!a���k	�	���k	�	�@@@�
@@@@���s\�������	2 [fallback a] returns the fallback value for [a]. ���j	^	^��j	^	�@@@@@@@���k	�	�@�@���Р&length���n	�	���n	�	�@��@����!t���n	�	���n	�	�@���!a���n	�	���n	�	�@@@@�	@@@����#int���n	�	���n	�	�@@�@@@�@@@@������������	' [length a] returns the length of [a]. ���m	�	���m	�	�@@@@@@@���n	�	�@�@���Р#get���s
�
���s
�
�@��@����!t���s
�
���s
�
�@���!a���s
�
���s
�
�@@@@�	@@@��@����#int���s
�
���s
�
�@@�@@@��!a���s
�
���s
�
�@@@�
@@@�@@@@����ѐ������	� [get a idx] returns the contents of the cell of index [idx] in
   [a]. If [idx] < 0 or [idx] >= [length a], [get a idx] =
   [fallback a]. ��
p	�	��r
v
�@@@@@@@��s
�
�@�@���Р#set��w)-�w)0@��@����!t�� w)6�!w)7@���!a��'w)3�(w)5@@@@�	@@@��@����#int��2w);�3w)>@@�@@@��@��!a��;w)B�<w)D@@@����$unit��Cw)H�Dw)L@@�@@@�@@@�@@@�"@@@@���3�������	| [set a idx value] updates the cell of index [idx] with [value].
    If [idx] < 0 or [idx] >= [length a], [a] is unchanged. ��Uu
�
��Vv
�(@@@@@@@��Xw))@�@���Р$iter��a{���b{��@��@��@��!a��k{���l{��@@@����$unit��s{���t{��@@�@@@�@@@��@����!t��{����{��@���!a���{����{��@@@@�	@@@����$unit���{����{��@@�@@@�@@@���{��@@@@���h�������	p [iter f a] iterates [f] over the cells of [a] from the
   cell indexed [0] to the cell indexed [length a - 1]. ���yNN��z��@@@@@@@���{��@�@���Р#map��� @���� @��@��@��@��!a��� @���� @��@@@��!b��� @���� @��@@@�	@@@��@����!t��� @���� @��@���!a��� @���� @��@@@@�	@@@����!t��� @���� @��@���!b��� @���� @��@@@@�	@@@�
@@@��� @��@@@@������������	� [map f a] computes a new array obtained by applying [f] to each
   cell contents of [a]. Notice that the fallback value of the new
   array is [f (fallback a)]. ���}����t�@@@@@@@��� @��@�@���Р$fold��� F���� F��@��@��@��!b�� F��� F��@@@��@��!a�� F��� F��@@@��!b�� F��� F��@@@�	@@@�@@@��@����!t��! F���" F��@���!a��( F���) F��@@@@�	@@@��@��!b��1 F���2 F��@@@��!b��7 F���8 F��@@@�	@@@�@@@��< F��@@@@���'�������	� [fold f a init] traverses [a] from the cell indexed [0] to the
   cell indexed [length a - 1] and transforms [accu] into [f accu x]
   where [x] is the content of the cell under focus. [accu] is
   [init] on the first iteration. ��I B���J E��@@@@@@@��L F��@�@���Р(fold_map��U O~��V O~�@��@��@��!b��_ O~��` O~�@@@��@��!a��g O~��h O~�@@@�����!b��p O~��q O~�@@@���!c��w O~��x O~�@@@@�
@@@�@@@�@@@��@����!t��� O~��� O~�@���!a��� O~��� O~�@@@@�	@@@��@��!b��� O~��� O~�@@@��@��!c��� O~��� O~�@@@�����!b��� O~��� O~�@@@�����!t��� O~��� O~�@���!c��� O~��� O~�@@@@�	@@@@�
@@@�@@@�'@@@�1@@@��� O~�@@@@������������
  � [fold_map f a init fallback] traverses [a] from the cell indexed
   [0] to the cell indexed [length a - 1] and transforms [accu] into
   [fst (f accu x)] where [x] is the content of the cell under
   focus. [accu] is [init] on the first iteration. The function also
   returns a fresh array containing [snd (f accu x)] for each [x].
   [fallback] is required to initialize a fresh array before it can be
   filled. ��� H���� Np}@@@@@@@��� O~~@� @@