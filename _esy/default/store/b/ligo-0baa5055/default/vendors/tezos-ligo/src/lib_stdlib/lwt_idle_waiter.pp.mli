Caml1999N029����   7         	5vendors/tezos-ligo/src/lib_stdlib/lwt_idle_waiter.mli����  �  !  y  ܠ����1ocaml.ppx.context��&_none_@@ �A����������)tool_name���*ppx_driver@@@����,include_dirs����"[]@@@����)load_path!����
%@%@@����,open_modules*����.@.@@����+for_package3����$None8@8@@����%debug=����%falseB@B@@����+use_threadsG����
K@K@@����-use_vmthreadsP����T@T@@����/recursive_typesY����]@]@@����)principalb����%f@f@@����3transparent_modulesk����.o@o@@����-unboxed_typest����7x@x@@����-unsafe_string}����@�@�@@����'cookies�����"::�����������,inline_tests�@�@@����(disabled��.<command-line>A@A�A@I@@��A@@�A@J@@@@�@@����������������,library-name�@�@@����,tezos_stdlib��A@A�A@M@@��A@N@@@@�@@�������@�@@@�@@�@@@�@@�@@@@�@@@�@�����A�    �!t��	5vendors/tezos-ligo/src/lib_stdlib/lwt_idle_waiter.mli]%*�]%+@@@@A@���)ocaml.docА������	� A lightweight scheduler to run tasks concurrently as well as
    special callbacks that must be run in mutual exclusion with the
    tasks (and each other). ��Z���\$@@@@@@@��]%%@@�@���Р&create��`ae�`ak@��@����$unit��&`an�'`ar@@�@@@����!t��/`av�0`aw@@�@@@�@@@@���0��������	. Creates a new task / idle callback scheduler ��?_--�@_-`@@@@@@@��B`aa@�@���Р$task��Ke	 	$�Le	 	(@��@����!t��Ue	 	+�Ve	 	,@@�@@@��@��@����$unit��be	 	1�ce	 	5@@�@@@�����#Lwt!t��me	 	<�ne	 	A@���!a��te	 	9�ue	 	;@@@@�	@@@�
@@@�����#Lwt!t���e	 	I��e	 	N@���!a���e	 	F��e	 	H@@@@�	@@@���e	 	0@@@�8@@@@����Y�������	� Schedule a task to be run as soon as no idle callback is running,
   or as soon as the next idle callback has been run if it was
   scheduled by {!force_idle}. ���byy��d�	@@@@@@@���e	 	 @�@���Р)when_idle���k
W
[��k
W
d@��@����!t���k
W
g��k
W
h@@�@@@��@��@����$unit���k
W
m��k
W
q@@�@@@�����#Lwt!t���k
W
x��k
W
}@���!a���k
W
u��k
W
w@@@@�	@@@�
@@@�����#Lwt!t���k
W
���k
W
�@���!a���k
W
���k
W
�@@@@�	@@@���k
W
l@@@�8@@@@������������
   Runs a callback as soon as no task is running. Does not prevent
    new tasks from being scheduled, the calling code should ensure
    that some idle time will eventually come. Calling this function
    from inside the callback will result in a dead lock. ���g	P	P��j

V@@@@@@@���k
W
W@�@���Р*force_idle���qim� qiw@��@����!t��	qiz�
qi{@@�@@@��@��@����$unit��qi��qi�@@�@@@�����#Lwt!t��!qi��"qi�@���!a��(qi��)qi�@@@@�	@@@�
@@@�����#Lwt!t��4qi��5qi�@���!a��;qi��<qi�@@@@�	@@@��?qi@@@�8@@@@���>�������	� Runs a callback as soon as possible. Lets all current tasks
    finish, but postpones all new tasks until the end of the
    callback. Calling this function from inside the callback will
    result in a dead lock. ��Mm
�
��NpKh@@@@@@@��Pqii@�@@