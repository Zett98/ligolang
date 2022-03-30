Caml1999N029����   -         	+vendors/tezos-ligo/src/lib_stdlib/utils.mli����  
�    �  i�����1ocaml.ppx.context��&_none_@@ �A����������)tool_name���*ppx_driver@@@����,include_dirs����"[]@@@����)load_path!����
%@%@@����,open_modules*����.@.@@����+for_package3����$None8@8@@����%debug=����%falseB@B@@����+use_threadsG����
K@K@@����-use_vmthreadsP����T@T@@����/recursive_typesY����]@]@@����)principalb����%f@f@@����3transparent_modulesk����.o@o@@����-unboxed_typest����7x@x@@����-unsafe_string}����@�@�@@����'cookies�����"::�����������,inline_tests�@�@@����(disabled��.<command-line>A@A�A@I@@��A@@�A@J@@@@�@@����������������,library-name�@�@@����,tezos_stdlib��A@A�A@M@@��A@N@@@@�@@�������@�@@@�@@�@@@�@@�@@@@�@@@�@��������%Infix��	+vendors/tezos-ligo/src/lib_stdlib/utils.mliZ���Z��@�����Р"--��\���\��@��@����#int��\���\��@@�@@@��@����#int��!\���"\��@@�@@@����$list��*\���+\��@�����#int��3\���4\��@@�@@@@�@@@�@@@�#@@@@���)ocaml.doc�������	4 Sequence: [i--j] is the sequence [i;i+1;...;j-1;j] ��F[���G[��@@@@@@@��I\��@� @@��LZ���M]��@@@��OZ��@�@���Р#cut��Xf	3	7�Yf	3	:@���$copy����$bool��df	3	C�ef	3	G@@�@@@��@����#int��of	3	K�pf	3	N@@�@@@��@�����%Bytes!t��|f	3	R�}f	3	Y@@�@@@����$list���f	3	e��f	3	i@������%Bytes!t���f	3	]��f	3	d@@�@@@@�@@@�@@@�'@@@���f	3	=@@@@���_d�������
  2 [cut ?copy size bytes] cut [bytes] the in a list of successive
    chunks of length [size] at most.

    If [copy] is false (default), the blocks of the list
    can be garbage-collected only when all the blocks are
    unreachable (because of the 'optimized' implementation of
    [sub] used internally. ���_����e		2@@@@@@@���f	3	3"@�#@���Р*do_n_times���j	�	���j	�	�@��@����#int���j	�	���j	�	�@@�@@@��@��@����$unit���j	�	���j	�	�@@�@@@����$unit���j	�	���j	�
 @@�@@@�@@@����$unit���j	�
��j	�
	@@�@@@���j	�	�@@@�&@@@@������������	j [do_n_times n f] executes [f] [n] times.
    If [n] is negative, [invalid_arg "do_n_times"] is executed. ���h	k	k��i	�	�@@@@@@@���j	�	�@�@���Р,fold_n_times���n

���n

�@��@����#int��n

��n

�@@�@@@��@��@��!a��n

��n

�@@@��!a��n

��n

�@@@�	@@@��@��!a��n

��n

�@@@��!a��"n

��#n

�@@@�	@@@��&n

�@@@�&@@@@������������	n [fold_n_times n f] composes [f] [n] times.
    If [n] is negative, [invalid_arg "fold_n_times"] is executed. ��4l

�5m
:
~@@@@@@@��7n

@�@@