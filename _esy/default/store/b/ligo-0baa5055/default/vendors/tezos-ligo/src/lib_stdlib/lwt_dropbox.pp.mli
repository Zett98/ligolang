Caml1999N029����   3         	1vendors/tezos-ligo/src/lib_stdlib/lwt_dropbox.mli����  �  �  
�  	������1ocaml.ppx.context��&_none_@@ �A����������)tool_name���*ppx_driver@@@����,include_dirs����"[]@@@����)load_path!����
%@%@@����,open_modules*����.@.@@����+for_package3����$None8@8@@����%debug=����%falseB@B@@����+use_threadsG����
K@K@@����-use_vmthreadsP����T@T@@����/recursive_typesY����]@]@@����)principalb����%f@f@@����3transparent_modulesk����.o@o@@����-unboxed_typest����7x@x@@����-unsafe_string}����@�@�@@����'cookies�����"::�����������,inline_tests�@�@@����(disabled��.<command-line>A@A�A@I@@��A@@�A@J@@@@�@@����������������,library-name�@�@@����,tezos_stdlib��A@A�A@M@@��A@N@@@@�@@�������@�@@@�@@�@@@�@@�@@@@�@@@�@�������*ocaml.textǐ������	$ A 'dropbox' with a single element. ��	1vendors/tezos-ligo/src/lib_stdlib/lwt_dropbox.mliZ���Z��@@@@@@���A�    �!t��]���]��@����!a��]���]��@@@�BA@@@A@���)ocaml.docꐠ�����	. Type of dropbox holding a value of type ['a] ��#\���$\��@@@@@@@��&]��@@�@������&Closed��0`3=�1`3C@��@@��5`33@��� 	�������	B The exception returned when trying to access a 'closed' dropbox. ��B_���C_�2@@@@@@@@�@���Р&create��Lcei�Mceo@��@����$unit��Vcer�Wcev@@�@@@����!t��_ce}�`ce~@���!a��fcez�gce|@@@@�	@@@�
@@@@���T=�������: Create an empty dropbox. ��vbEE�wbEd@@@@@@@��ycee@�@���Р#put���j	Z	^��j	Z	a@��@����!t���j	Z	g��j	Z	h@���!a���j	Z	d��j	Z	f@@@@�	@@@��@��!a���j	Z	l��j	Z	n@@@����$unit���j	Z	r��j	Z	v@@�@@@�@@@�@@@@����|�������	� [put t e] puts the element [e] inside the dropbox [t]. If the dropbox
    already held an element, the old element is discarded and replaced by the
    new one.

    @raise [Close] if [close t] has been called. ���e����i	&	Y@@@@@@@���j	Z	Z@�@���Р$take���t
�
���t
�
�@��@����!t���t
�
���t
�
�@���!a���t
�
���t
�
�@@@@�	@@@�����#Lwt!t���t
�
���t
�
�@���!a���t
�
���t
�
�@@@@�	@@@�
@@@@������������
  d [take t] is a promise that resolves as soon as an element is held by [t].
    The element is removed from [t] when the promise resolves.

    If [t] already holds an element when [take t] is called, the promise
    resolves immediately. Otherwise, the promise resolves when an element is
    [put] there.

    @raise [Close] if [close t] has been called. ���l	x	x��s
�
�@@@@@@@���t
�
�@�@���Р1take_with_timeout�� }FJ�}F[@��@�����#Lwt!t��}Fc�}Fh@�����$unit��}F^�}Fb@@�@@@@�@@@��@����!t��!}Fo�"}Fp@���!a��(}Fl�)}Fn@@@@�	@@@�����#Lwt!t��3}F~�4}F�@�����&option��<}Fw�=}F}@���!a��C}Ft�D}Fv@@@@�	@@@@�@@@� @@@�4@@@@���3�������
  A [take_with_timeout timeout t] behaves like [take t] except that it returns
    [None] if [timeout] resolves before an element is [put].

    Note that [timeout] is canceled (i.e., fails with [Canceled]) if an element
    is [put] in time (or if one is already present).

    @raise [Close] if [close t] has been called. ��Uv
�
��V|E@@@@@@@��X}FF%@�&@���Р$peek��a C�b C@��@����!t��k C#�l C$@���!a��r C �s C"@@@@�	@@@����&option��{ C+�| C1@���!a��� C(�� C*@@@@�	@@@�
@@@@���pY�������	� [peek t] is [Some e] if [t] holds [e] and [None] if [t] does not hold any
    element.

    @raise [Close] if [close t] has been called. ������� B�@@@@@@@��� C@�@���Р%close��� Jdh�� Jdm@��@����!t��� Jds�� Jdt@���!a��� Jdp�� Jdr@@@@�	@@@����$unit��� Jdx�� Jd|@@�@@@�@@@@������������
  + [close t] closes the dropbox [t]. It terminates all the waiting reader with
    the exception [Closed]. All further read or write will also immediately
    fail with [Closed], except if the dropbox is not empty when
    [close] is called. In that case, a single (and last) [take] will
    succeed. ��� E33�� ITc@@@@@@@��� Jdd@�@@