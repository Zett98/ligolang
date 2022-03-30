Caml1999N029����   0         	.vendors/tezos-ligo/src/lib_stdlib/lwt_pipe.mli����  )�    .  m�����1ocaml.ppx.context��&_none_@@ �A����������)tool_name���*ppx_driver@@@����,include_dirs����"[]@@@����)load_path!����
%@%@@����,open_modules*����.@.@@����+for_package3����$None8@8@@����%debug=����%falseB@B@@����+use_threadsG����
K@K@@����-use_vmthreadsP����T@T@@����/recursive_typesY����]@]@@����)principalb����%f@f@@����3transparent_modulesk����.o@o@@����-unboxed_typest����7x@x@@����-unsafe_string}����@�@�@@����'cookies�����"::�����������,inline_tests�@�@@����(disabled��.<command-line>A@A�A@I@@��A@@�A@J@@@@�@@����������������,library-name�@�@@����,tezos_stdlib��A@A�A@M@@��A@N@@@@�@@�������@�@@@�@@�@@@�@@�@@@@�@@@�@�������*ocaml.textǐ������	� Data queues similar to the [Pipe] module in Jane Street's [Async]
    library. They are implemented with [Queue]s, limited in size, and
    use Lwt primitives for concurrent access. ��	.vendors/tezos-ligo/src/lib_stdlib/lwt_pipe.mliZ���\=@@@@@@���A�    �!t��_rz�_r{@����!a��_rw�_ry@@@�BA@@@A@���)ocaml.docꐠ�����	- Type of queues holding values of type ['a]. ��#^??�$^?q@@@@@@@��&_rr@@�@���Р&create��/rIM�0rIS@���$size�������#int��>rI\�?rI_@@�@@@���@��!a��HrIc�IrIe@@@����#int��PrIi�QrIl@@�@@@�@@@@��UrIm@@@��@����$unit��^rIq�_rIu@@�@@@����!t��grI|�hrI}@���!a��nrIy�orI{@@@@�	@@@�
@@@��srIV@@@@���^G�������
  � [create ~size:(max_size, compute_size) ()] is an empty queue that can
    hold max [size] "bytes" of data, using [compute_size] to compute the
    number of "bytes" in a datum.

    Note that you can use [size] to actually limit the size in byte (i.e., the
    memory foot-print of the structure (in this case, consider using
    {!push_overhead} to account for the boilerplate memory), but you can also
    use [size] to limit the foot-print of the structure for some other resource.
    E.g., you can spin up tasks in separate processes and limit the number of
    concurrently running processes.

    Also note that the size bound is not inclusive. So with [size] set to
    [(2, fun _ -> 1)] you can add one (1) element and then the pipe is full. (It
    is full because adding any other element would take the total size to [2]
    which is not strictly smaller than the [max_size] bound.)

    If you do not provide a [size] argument, the queue is unbounded. ���a}}��qH@@@@@@@���rII@�@���Р$push��� D���� D��@��@����!t��� D���� D��@���!a��� D���� D��@@@@�	@@@��@��!a��� D���� D��@@@�����#Lwt!t��� D���� D��@�����$unit��� D���� D��@@�@@@@�@@@�@@@�"@@@@������������
   [push q v] is a promise that is pending until there is enough space in [q]
    to accommodate [v]. When this happens [v] is added to the end of [q] and the
    promise resolves.

    If there is enough space in [q] to accommodate [v] when the call is made,
    then the [v] is added immediately and an already resolved promise is
    returned.

    Note that if several writes are stuck because the pipe is full. These
    writes will succeed in an order that might be different from the order the
    write attempts were made. Specifically, when pushing elements of different
    computed sizes, smaller pushes may be resolved earlier if enough space is
    freed.

    @raise {!Closed} if [q] is closed. More specifically, the promise is
    rejected with {!Closed} if [q] is closed. ���t�� Cg�@@@@@@@��� D��@�@���Р#pop��� N��� N�@��@����!t��� N��� N�@���!a��� N��� N�@@@@�	@@@�����#Lwt!t��� N��� N�@���!a��� N��� N�@@@@�	@@@�
@@@@����ѐ������
  � [pop q] is a promise that is pending until there is an element in [q]. When
    this happens an element is removed and the promise is fulfilled with it.

    If there is already an element in [q] when the call is made, the element is
    removed immediately and an already resolved promise is returned.

    @raise {!Closed} if [q] is empty and closed. More specifically, the promise
    is rejected with {!Closed} if [q] is empty and closed. ��
 F��� MA~@@@@@@@�� N@�@���Р0pop_with_timeout�� \� \*@��@�����#Lwt!t��" \2�# \7@�����$unit��+ \-�, \1@@�@@@@�@@@��@����!t��7 \>�8 \?@���!a��> \;�? \=@@@@�	@@@�����#Lwt!t��I \M�J \R@�����&option��R \F�S \L@���!a��Y \C�Z \E@@@@�	@@@@�@@@� @@@�4@@@@���I2�������
  u [pop_with_timeout t q] is a promise that behaves similarly to [pop q]
    except that it resolves with [None] if [t] resolves before there is an
    element in [q] to pop.

    Note that there can be multiple promises that are awaiting for an element to
    pop from the queue. As a result, it is possible that [pop_with_timeout] is
    fulfilled with [None] even though values have been pushed to the [q].

    [t] is canceled (i.e., it fails with [Canceled]) if an element is returned.

    @raise {!Closed} if [q] is empty and closed. More specifically, the promise
    is rejected with {!Closed} if [q] is empty and closed. ��k P���l [�@@@@@@@��n \%@�&@���Р'pop_all��w hpt�x hp{@��@����!t��� hp��� hp�@���!a��� hp~�� hp�@@@@�	@@@�����#Lwt!t��� hp��� hp�@�����$list��� hp��� hp�@���!a��� hp��� hp�@@@@�	@@@@�@@@� @@@@����{�������
   [pop_all q] is a promise that is pending until there is an element in [q].
    When this happens, all the elements of [q] are removed and the promise is
    fulfilled with the list of elements (in the order in which they were
    inserted).

    If there is already an element in [q] when the call is made, the elements
    are removed immediately and an already resolved promise is returned.

    @raise {!Closed} if [q] is empty and closed. More specifically, the promise
    is rejected with {!Closed} if [q] is empty and closed. ��� ^TT�� g2o@@@@@@@��� hpp$@�%@���Р+pop_all_now��� n]a�� n]l@��@����!t��� n]r�� n]s@���!a��� n]o�� n]q@@@@�	@@@����$list��� n]z�� n]~@���!a��� n]w�� n]y@@@@�	@@@�
@@@@������������	� [pop_all_now q] removes and returns all the elements in [q] (in the order in
    which they were inserted). If [q] is empty, [[]] is returned.

    @raise {!Closed} if [q] is empty and closed. ��� j���� m)\@@@@@@@��� n]]@�@���Р$peek��� ulp�� ult@��@����!t�� ulz� ul{@���!a�� ulw� uly@@@@�	@@@�����#Lwt!t�� ul�� ul�@���!a��  ul�! ul�@@@@�	@@@�
@@@@�����������	� [peek q] returns the same value as [pop q] but does not remove the returned
    element.

    @raise {!Closed} if [q] is empty and closed. More specifically, the promise
    is rejected with {!Closed} if [q] is empty and closed. ��0 p���1 t.k@@@@@@@��3 ull@�@���Р(peek_all��< {;?�= {;G@��@����!t��F {;M�G {;N@���!a��M {;J�N {;L@@@@�	@@@����$list��V {;U�W {;Y@���!a��] {;R�^ {;T@@@@�	@@@�
@@@@���K4�������	� [peek_all q] returns the elements in the [q] (oldest first), or [[]] if
    empty. It does not remove elements from [q].

    @raise {!Closed} if [q] is empty and closed. ��m w���n z:@@@@@@@��p {;;@�@���Р(push_now��y ����z ���@��@����!t��� ����� ���@���!a��� ����� ���@@@@�	@@@��@��!a��� ����� ���@@@����$bool��� ���� ��@@�@@@�@@@�@@@@����s�������	� [push_now q v] either
    - adds [v] at the ends of [q] immediately and returns [true], or
    - if [q] is full, returns [false]. ��� }[[�� ��@@@@@@@��� ���@�@���Р'pop_now��� �sw�� �s~@��@����!t��� �s��� �s�@���!a��� �s��� �s�@@@@�	@@@����&option��� �s��� �s�@���!a��� �s��� �s�@@@@�	@@@�
@@@@������������	f [pop_now q] may remove and return the first element in [q] if
    [q] contains at least one element. ��� ��� �Ir@@@@@@@��� �ss@�@���Р&length��� ����� ���@��@����!t��� ����  ���@���!a�� ���� ���@@@@�	@@@����#int�� ���� ���@@�@@@�@@@@����搠�����	. [length q] is the number of elements in [q]. �� ����  ���@@@@@@@��" ���@�@���Р(is_empty��+ �$(�, �$0@��@����!t��5 �$6�6 �$7@���!a��< �$3�= �$5@@@@�	@@@����$bool��E �$;�F �$?@@�@@@�@@@@���3�������	< [is_empty q] is [true] if [q] is empty, [false] otherwise. ��U ����V ��#@@@@@@@��X �$$@�@���Р%empty��a ����b ���@��@����!t��k ����l ���@���!a��r ����s ���@@@@�	@@@�����#Lwt!t��} ����~ ���@�����$unit��� ����� ���@@�@@@@�@@@�@@@@���u^�������	> [empty q] is a promise that resolves when [q] becomes empty. ��� �AA�� �A�@@@@@@@��� ���@�@������&Closed��� ����� ���@��@@��� ���@@z@�@���Р%close��� �	�� �@��@����!t��� ��� �@���!a��� ��� �@@@@�	@@@����$unit��� ��� �@@�@@@�@@@@������������
  H [close q] the write-end of [q]:

    * Future write attempts will fail with {!Closed}.
    * If there are pending reads, they will become rejected with {!Closed}.
    * Future read attempts will drain the data until there is no data left (at
      which point {!Closed} may be raised).

    The [close] function is idempotent. ��� ����� ��@@@@@@@��� �@�@���Р)is_closed��� �#�� �,@��@����!t��� �2�� �3@���!a��� �/�� �1@@@@�	@@@����$bool�� �7� �;@@�@@@�@@@@@�� �@�@���Р-push_overhead�� ���� ���@����#int�� ���� ���@@�@@@@��������	^ The number of bytes used in the internal representation to hold an element
    in the queue. ��' �==�( ���@@@@@@@��* ���@�@@