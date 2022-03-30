Caml1999N029����   7         	5vendors/tezos-ligo/src/lib_stdlib/circular_buffer.mli����  �  �  
�  	ɠ����1ocaml.ppx.context��&_none_@@ �A����������)tool_name���*ppx_driver@@@����,include_dirs����"[]@@@����)load_path!����
%@%@@����,open_modules*����.@.@@����+for_package3����$None8@8@@����%debug=����%falseB@B@@����+use_threadsG����
K@K@@����-use_vmthreadsP����T@T@@����/recursive_typesY����]@]@@����)principalb����%f@f@@����3transparent_modulesk����.o@o@@����-unboxed_typest����7x@x@@����-unsafe_string}����@�@�@@����'cookies�����"::�����������,inline_tests�@�@@����(disabled��.<command-line>A@A�A@I@@��A@@�A@J@@@@�@@����������������,library-name�@�@@����,tezos_stdlib��A@A�A@M@@��A@N@@@@�@@�������@�@@@�@@�@@@�@@�@@@@�@@@�@�������*ocaml.textǐ������
  b This module implements a bufferisation abstraction to store
   temporary raw data chunks (as bytes) when chunks are read
   sequentially. The function [write] allows to store chunks in the
   buffer and the function read to read them from the buffer.

   The global contract is that if we write consecutively [d1;d2] onto
   the buffer, then we have to fully read [d1] and [d2], in that order.

   This contract is not enforced by the library, it is the user
   responsibility to respect it.

   If the circular buffer is full, a new temporary buffer is
   allocated to store the chunk of data to be written. ��	5vendors/tezos-ligo/src/lib_stdlib/circular_buffer.mliZ���f	�	�@@@@@@���A�    �!t��i

�i

@@@@A@���)ocaml.docᐠ�����; Type of circular buffers  ��h	�	��h	�

@@@@@@@��i

@@�@���A�    �$data��'l
U
Z�(l
U
^@@@@A@�����������	< An abstraction over a chunk of data written in the buffer. ��5k

�6k

T@@@@@@@��8l
U
U@@�@���Р&create��Aq,0�Bq,6@���)maxlength����#int��Mq,D�Nq,G@@�@@@���.fresh_buf_size����#int��Zq,[�[q,^@@�@@@��@����$unit��eq,b�fq,f@@�@@@����!t��nq,j�oq,k@@�@@@�@@@��sq,K@@@��uq,9@@@@���iI�������	� [create ?maxlength ?fresh_buf_size ()] creates a buffer of size [maxlength]
    (by default [32] kb). If the buffer is full, a buffer of size [fresh_buf_size]
    is allocated (by default [2] kb). ���n
`
`��p+@@@@@@@���q,,@�@���Р%write���~��~"@���&maxlen����#int���%.��%1@@�@@@���*fill_using��@�����%Bytes!t��� @5C�� @5J@@�@@@��@����#int��� @5N�� @5Q@@�@@@��@����#int��� @5U�� @5X@@�@@@�����#Lwt!t��� @5`�� @5e@�����#int��� @5\�� @5_@@�@@@@�@@@�@@@�%@@@�1@@@��@����!t��� Ajl�� Ajm@@�@@@�����#Lwt!t��� Bqx�� Bq}@�����$data��� Bqs�� Bqw@@�@@@@�@@@�@@@��� @57@@@�� %'@@@@����Ԑ������
  � [write ~maxlen ~fill_using buffer] calls [fill_using buf offset
   maxlen] where [buf] is a buffer that has room for [maxlen] data
   starting from [offset].

   Assumes that [fill_using] returns the exact amount of written
   bytes.

   Behaviour is unspecified if [fill_using] writes more than [maxlen]
   data or lies on the number of written bytes.

   It returns a data descriptor for the supposedly written chunk.  ��smm�}�@@@@@@@��~!@�"@���Р$read�� L
� L@��@����$data��# L�$ L@@�@@@���#len����#int��0 L�1 L!@@�@@@��@����!t��; L%�< L&@@�@@@���$into�����%Bytes!t��J L/�K L6@@�@@@���&offset����#int��W LA�X LD@@�@@@����&option��` LM�a LS@�����$data��i LH�j LL@@�@@@@�@@@��n L:@@@��p L*@@@�7@@@��s L@@@�R@@@@���hH�������
  � [read data ~len ~into:buf buffer ~offset] copies [len] data from the [data] chunk into [buf].
    If [len] is not provided, it copies all the data.
    If [len] is less than the amount of data available, it returns a
    new handler of the remainder.

    - Assumes that [data] has been produced by a {!write} attempt in [buffer].
    - Assumes that [len] is less than [length data].
��� D�� K@@@@@@@��� L$@�%@���Р&length��� O���� O��@��@����$data��� O���� O��@@�@@@����#int��� O���� O��@@�@@@�@@@@����w�������	? [length data] returns the amount of available bytes in [data] ��� NUU�� NU�@@@@@@@��� O��@�@@