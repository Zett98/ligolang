Caml1999N029����   7         	5vendors/tezos-ligo/src/lib_stdlib/functionalArray.mli����    �    ������1ocaml.ppx.context��&_none_@@ �A����������)tool_name���*ppx_driver@@@����,include_dirs����"[]@@@����)load_path!����
%@%@@����,open_modules*����.@.@@����+for_package3����$None8@8@@����%debug=����%falseB@B@@����+use_threadsG����
K@K@@����-use_vmthreadsP����T@T@@����/recursive_typesY����]@]@@����)principalb����%f@f@@����3transparent_modulesk����.o@o@@����-unboxed_typest����7x@x@@����-unsafe_string}����@�@�@@����'cookies�����"::�����������,inline_tests�@�@@����(disabled��.<command-line>A@A�A@I@@��A@@�A@J@@@@�@@����������������,library-name�@�@@����,tezos_stdlib��A@A�A@M@@��A@N@@@@�@@�������@�@@@�@@�@@@�@@�@@@@�@@@�@�������*ocaml.textǐ������
  �

   This module implements functional arrays equipped with accessors
   that cannot raise exceptions following the same design principles
   as {!FallbackArray}:

   Reading out of the bounds of the arrays return a fallback value
   fixed at array construction time, writing out of the bounds of the
   arrays is ignored.

   Contrary to {!FallbackArray}, writing generates a fresh array.

   Please notice that this implementation is naive and should only
   be used for small arrays. If there is a need for large functional
   arrays, it is recommended to implement Backer's trick to get
   constant-time reads and writes for sequences of mutations applied
   to the same array.

��	5vendors/tezos-ligo/src/lib_stdlib/functionalArray.mliZ���l
/
1@@@@@@���A�    �!t��o
m
u�o
m
v@����!a��o
m
r�o
m
t@@@�BA@@@A@���)ocaml.docꐠ�����	4 The type for array containing values of type ['a]. ��#n
3
3�$n
3
l@@@@@@@��&o
m
m@@�@���Р$make��/s
�
��0s
�
�@��@����#int��9s
�
��:s
�@@�@@@��@��!a��Bs
��Cs
�@@@����!t��Js
��Ks
�@���!a��Qs
��Rs
�@@@@�	@@@�
@@@�@@@@���@)�������	u [make len v] builds an array [a] initializing [len] cells with
   [v]. The value [v] is the fallback value for [a]. ��bq
x
x�cr
�
�@@@@@@@��es
�
�@�@���Р$init��nx���ox��@��@����#int��xx���yx��@@�@@@��@��!a���x����x��@@@��@��@����#int���x����x��@@�@@@��!a���x����x��@@@�
@@@����!t���x����x��@���!a���x����x��@@@@�	@@@���x��@@@�)@@@�3@@@@����~�������	� [init len v make] builds an array [a] initializing [len] cells
    where the [i]-th cell value is [make i]. The value [v] is the
    fallback value for [a]. ���u��w��@@@@@@@���x��@�@���Р(fallback���{��{&@��@����!t���{,��{-@���!a���{)��{+@@@@�	@@@��!a���{1��{3@@@�
@@@@������������	2 [fallback a] returns the fallback value for [a]. ���z����z�@@@@@@@���{@�@���Р&length���~bf��~bl@��@����!t�� ~br�~bs@���!a��~bo�~bq@@@@�	@@@����#int��~bw�~bz@@�@@@�@@@@����琠�����	' [length a] returns the length of [a]. �� }55�!}5a@@@@@@@��#~bb@�@���Р#get��, C�- C@��@����!t��6 C�7 C@���!a��= C�> C@@@@�	@@@��@����#int��H C �I C#@@�@@@��!a��O C'�P C)@@@�
@@@�@@@@���=&�������	� [get a idx] returns the contents of the cell of index [idx] in
   [a]. If [idx] < 0 or [idx] >= [length a], [get a idx] =
   [fallback a]. ��_ @||�` B�@@@@@@@��b C@�@���Р#set��k H���l H��@��@����!t��u H���v H��@���!a��| H���} H��@@@@�	@@@��@����#int��� H���� H��@@�@@@��@��!a��� H���� H��@@@����!t��� H���� H� @���!a��� H���� H��@@@@�	@@@�
@@@�@@@�)@@@@����x�������	� [set a idx value] returns a new array identical to [a] except
   that the cell of index [idx] with [value].
   If [idx] < 0 or [idx] >= [length a], returns a copy of [a]. ��� E++�� G��@@@@@@@��� H��@�@���Р$iter��� Lx|�� Lx�@��@��@��!a��� Lx��� Lx�@@@����$unit��� Lx��� Lx�@@�@@@�@@@��@����!t��� Lx��� Lx�@���!a��� Lx��� Lx�@@@@�	@@@����$unit��� Lx��� Lx�@@�@@@�@@@��� Lx�@@@@����Đ������	p [iter f a] iterates [f] over the cells of [a] from the
   cell indexed [0] to the cell indexed [length a - 1]. ��� J�� K=w@@@@@@@��  Lxx@�@���Р%iteri��	 Q9=�
 Q9B@��@��@����#int�� Q9F� Q9I@@�@@@��@��!a�� Q9M� Q9O@@@����$unit��& Q9S�' Q9W@@�@@@�@@@�@@@��@����!t��3 Q9_�4 Q9`@���!a��: Q9\�; Q9^@@@@�	@@@����$unit��C Q9d�D Q9h@@�@@@�@@@��H Q9E@@@@���3�������	� [iteri f a] iterates [f] over the cells of [a] from the
   cell indexed [0] to the cell indexed [length a - 1] passing
   the cell index to [f]. ��U N���V P8@@@@@@@��X Q99@�@���Р#map��a V�b V@��@��@��!a��k V�l V@@@��!b��q V!�r V#@@@�	@@@��@����!t��| V+�} V,@���!a��� V(�� V*@@@@�	@@@����!t��� V3�� V4@���!b��� V0�� V2@@@@�	@@@�
@@@��� V@@@@����l�������	� [map a] computes a new array obtained by applying [f] to each
   cell contents of [a]. Notice that the fallback value of the new
   array is [f (fallback a)]. ��� Sjj�� U�@@@@@@@��� V@�@���Р$mapi��� [�� [@��@��@����#int��� [�� [@@�@@@��@��!a��� [�� [ @@@��!b��� [$�� [&@@@�	@@@�@@@��@����!t��� [.�� [/@���!a��� [+�� [-@@@@�	@@@����!t��� [6�� [7@���!b��� [3�� [5@@@@�	@@@�
@@@��� [@@@@����Ȑ������	� [mapi f a] computes a new array obtained by applying [f] to each
   cell contents of [a] passing the index of this cell to [i].
    Notice that the fallback value of the new array is [f (-1) (fallback a)]. �� X66� Z�
@@@@@@@�� [@�@���Р$fold�� a%)� a%-@��@��@��!b�� a%1� a%3@@@��@��!a�� a%7�  a%9@@@��!b��% a%=�& a%?@@@�	@@@�@@@��@����!t��1 a%G�2 a%H@���!a��8 a%D�9 a%F@@@@�	@@@��@��!b��A a%L�B a%N@@@��!b��G a%R�H a%T@@@�	@@@�@@@��L a%0@@@@���7 �������	� [fold f a init] traverses [a] from the cell indexed [0] to the
   cell indexed [length a - 1] and transforms [accu] into [f accu x]
   where [x] is the content of the cell under focus. [accu] is
   [init] on the first iteration. ��Y ]99�Z ` $@@@@@@@��\ a%%@�@���Р(fold_map��e j� �f j�@��@��@��!b��o j��p j�@@@��@��!a��w j��x j�@@@�����!b��� j��� j�@@@���!c��� j��� j�@@@@�
@@@�@@@�@@@��@����!t��� j�'�� j�(@���!a��� j�$�� j�&@@@@�	@@@��@��!b��� j�,�� j�.@@@��@��!c��� j�2�� j�4@@@�����!b��� j�8�� j�:@@@�����!t��� j�@�� j�A@���!c��� j�=�� j�?@@@@�	@@@@�
@@@�@@@�'@@@�1@@@��� j�@@@@������������
  � [fold_map f a init fallback] traverses [a] from the cell indexed
   [0] to the cell indexed [length a - 1] and transforms [accu] into
   [fst (f accu x)] where [x] is the content of the cell under
   focus. [accu] is [init] on the first iteration. The function also
   returns a fresh array containing [snd (f accu x)] for each [x].
   [fallback] is required to initialize a fresh array before it can be
   filled. ��� cVV�� i��@@@@@@@��� j��@� @@