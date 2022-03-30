Caml1999N029����   1         	/vendors/tezos-ligo/src/lib_stdlib/lwt_utils.mli����  N  �  �  
������1ocaml.ppx.context��&_none_@@ �A����������)tool_name���*ppx_driver@@@����,include_dirs����"[]@@@����)load_path!����
%@%@@����,open_modules*����.@.@@����+for_package3����$None8@8@@����%debug=����%falseB@B@@����+use_threadsG����
K@K@@����-use_vmthreadsP����T@T@@����/recursive_typesY����]@]@@����)principalb����%f@f@@����3transparent_modulesk����.o@o@@����-unboxed_typest����7x@x@@����-unsafe_string}����@�@�@@����'cookies�����"::�����������,inline_tests�@�@@����(disabled��.<command-line>A@A�A@I@@��A@@�A@J@@@@�@@����������������,library-name�@�@@����,tezos_stdlib��A@A�A@M@@��A@N@@@@�@@�������@�@@@�@@�@@@�@@�@@@@�@@@�@�����Р,never_ending��	/vendors/tezos-ligo/src/lib_stdlib/lwt_utils.mli[���[��@��@����$unit��[���[��@@�@@@�����#Lwt!t��[���[��@���!a��[���[��@@@@�	@@@�
@@@@@��"[��@�@���Р&worker��+wx|�,wx�@��@����&string��5x���6x��@@�@@@���(on_event��@����&string��Dy���Ey��@@�@@@��@������%Ended��Qy���Ry��@A@�@@����&Failed��Zy���[y��@@�����&string��cy���dy��@@�@@@@�@@����'Started��my���ny��@A@�@@@@@��qy���ry��@@@�����#Lwt!t��{y���|y��@�����$unit���y����y��@@�@@@@�@@@�@@@�F@@@���#run��@����$unit���z����z��@@�@@@�����#Lwt!t���z����z��@�����$unit���z����z��@@�@@@@�@@@�@@@���&cancel��@����$unit���{�	��{�@@�@@@�����#Lwt!t���{���{�@�����$unit���{���{�@@�@@@@�@@@�@@@�����#Lwt!t���| '��| ,@�����$unit���| "��| &@@�@@@@�@@@���{�@@@���z��@@@���y��@@@��@@@@���)ocaml.doc��������
  | [worker name ~on_event ~run ~cancel] internally calls [run ()] (which
    returns a promise [p]) and returns its own promise [work].
    If [p] becomes fulfilled, then [work] also becomes fulfilled.
    If [p] becomes rejected then [cancel ()] is called and, once its promise is
    resolved, [work] is fulfilled. This gives the opportunity for the function
    [cancel] to clean-up some resources.

    The function [on_event] is called at different times (start, failure, end)
    and is mostly meant as a logging mechanism but can also be used for other
    purposes such as synchronization between different workers.

    If the promises returned by [on_event] or [cancel] raise an exception or
    become rejected, the exception/failure is simply ignored and the promise is
    treated as having resolved anyway.

    Note that the promise [work] returned by the [worker] function is not
    cancelable. If you need to cancel the promise returned by [run], you need
    to embed your own synchronization system within [run]. E.g.,

    [let p, r = Lwt.wait in
     let run () =
        let main = … in
        Lwt.pick [main ; p]
     in]

���]����vuw@@@@@@@�� wxx$@�%@���Р-fold_left_s_n��	 @���
 @��@���!n����#int�� A��� A��@@�@@@��@��@��!a��  A���! A��@@@��@��!b��( A���) A��@@@�����#Lwt!t��2 A���3 A��@���!a��9 A���: A��@@@@�	@@@�
@@@�@@@��@��!a��D A���E A��@@@��@����$list��N A��O A�	@���!b��U A��V A�@@@@�	@@@�����#Lwt!t��` A��a A�!@������!a��j A��k A�@@@�����$list��s A��t A�@���!b��z A��{ A�@@@@�	@@@@�
@@@@�� A�@@@�, @@@�>!@@@��� A��#@@@��� A��%@@@@����Q�������	� Evaluates fold_left_s on a batch of [n] elements and returns a pair
    containing the result of the first batch and the unprocessed elements ���~..��v�@@@@@@@��� @��5@�6@���Р*find_map_s��� DKO�� DKY@��@��@��!a��� DK]�� DK_@@@�����#Lwt!t��� DKm�� DKr@�����&option��� DKf�� DKl@���!b��� DKc�� DKe@@@@�	@@@@�@@@�@@@��@����$list��� DKz�� DK~@���!a��� DKw�� DKy@@@@�	@@@�����#Lwt!t��� DK��� DK�@�����&option��� DK��� DK�@���!b��� DK��� DK�@@@@�	@@@@�@@@� @@@��� DK\@@@@���Ð������	" Lwt version of [TzList.find_map] �� C##� C#J@@@@@@@�� DKK&@�'@@