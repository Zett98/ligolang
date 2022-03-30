Caml1999N029����   4         	2vendors/tezos-ligo/src/lib_stdlib/bounded_heap.mli����     �  �  �����1ocaml.ppx.context��&_none_@@ �A����������)tool_name���*ppx_driver@@@����,include_dirs����"[]@@@����)load_path!����
%@%@@����,open_modules*����.@.@@����+for_package3����$None8@8@@����%debug=����%falseB@B@@����+use_threadsG����
K@K@@����-use_vmthreadsP����T@T@@����/recursive_typesY����]@]@@����)principalb����%f@f@@����3transparent_modulesk����.o@o@@����-unboxed_typest����7x@x@@����-unsafe_string}����@�@�@@����'cookies�����"::�����������,inline_tests�@�@@����(disabled��.<command-line>A@A�A@I@@��A@@�A@J@@@@�@@����������������,library-name�@�@@����,tezos_stdlib��A@A�A@M@@��A@N@@@@�@@�������@�@@@�@@�@@@�@@�@@@@�@@@�@�������*ocaml.textǐ������	8 Bounded sequence: keep only the [n] greatest elements. ��	2vendors/tezos-ligo/src/lib_stdlib/bounded_heap.mliZ���Z��@@@@@@������$Make��\���\��@�����!E��\���\��@�����#Set+OrderedType��\���\��@�@@�����A�    �!t��+]���,]��@@@@A@@��.]��@@�@���Р&create��7c���8c��@��@����#int��Ac���Bc��@@�@@@����!t��Jc���Kc��@@�@@@�@@@@���)ocaml.doc"�������	� [create size] create a bounded sequence of at most [size] elements.

      Raise [Invalid_argument] if [size < 0] or [size > Sys.max_array_length].
   ��[_���\b��@@@@@@@��^c��@�@���Р&insert��gk	�	��hk	�	�@��@�����!E!t��sk	�	��tk	�	�@@�@@@��@����!t��~k	�	��k	�	�@@�@@@����$unit���k	�	���k	�	�@@�@@@�@@@�@@@@���>_�������
  # [insert e b] adds element [e] to bounded sequence [b] if:
      - [b] is not full (i.e, we have not inserted [size] elements until now); or
      - there is an element [e'] from [b] such that [E.compare e' e < 0]. 

      Worst-case complexity: O(log n) where n is the size of the heap.
   ���e����j	�	�@@@@@@@���k	�	�@�@���Р#get���r
�
���r
�
�@��@����!t���r
�
���r
�
�@@�@@@����$list���r
�
���r
�
�@������!E!t���r
�
���r
�
�@@�@@@@�@@@�@@@@���y��������	� [get b] returns the contents of [b] as a sorted list in increasing order
     according to [E.compare].

     Worst-case complexity: O(n log n) where n is the size of the heap.
   ���m	�	���q
�
�@@@@@@@���r
�
�@� @���Р$peek���y����y��@��@����!t���y����y��@@�@@@����&option���y����y��@������!E!t���y����y��@@�@@@@�@@@�@@@@����Ր������	� [peek b] returns [Some e] if [b] is not empty where [e] is the smallest
     element in [b] according to [E.compare], [None] otherwise.

     Worst-case complexity: O(1).
   ��t
�
��x��@@@@@@@��y��@� @@��\���z��@@��\��@@@��\��@�@@