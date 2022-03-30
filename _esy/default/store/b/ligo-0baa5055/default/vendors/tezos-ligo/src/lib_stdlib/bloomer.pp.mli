Caml1999N029����   /         	-vendors/tezos-ligo/src/lib_stdlib/bloomer.mli����    1  p  ʠ����1ocaml.ppx.context��&_none_@@ �A����������)tool_name���*ppx_driver@@@����,include_dirs����"[]@@@����)load_path!����
%@%@@����,open_modules*����.@.@@����+for_package3����$None8@8@@����%debug=����%falseB@B@@����+use_threadsG����
K@K@@����-use_vmthreadsP����T@T@@����/recursive_typesY����]@]@@����)principalb����%f@f@@����3transparent_modulesk����.o@o@@����-unboxed_typest����7x@x@@����-unsafe_string}����@�@�@@����'cookies�����"::�����������,inline_tests�@�@@����(disabled��.<command-line>A@A�A@I@@��A@@�A@J@@@@�@@����������������,library-name�@�@@����,tezos_stdlib��A@A�A@M@@��A@N@@@@�@@�������@�@@@�@@�@@@�@@�@@@@�@@@�@�����A�    �!t��	-vendors/tezos-ligo/src/lib_stdlib/bloomer.mlionv�onw@����!a��	ons�
onu@@@�BA@@@A@���)ocaml.docِ������
  7 A probabilistic set implementation in a fixed memory buffer, with
    an optional best-effort cleanup mechanism. The bigger the memory
    buffer, the less false positive outcomes of [mem].

    In a standard bloom filter, element membership is encoded as bits being
    equal to 1 at indices obtained by hashing said element. In this
    implementation, elements are associated not to bits but to counters.

    The [countdown] function decrements the counter associated to an element.
    Hence, each counter corresponds to the number of calls to the [countdown]
    function before they are removed from the filter, assuming no collision
    occurs.

    To the best of our knowledge, the variant of bloom filters implemented
    in this module is new. In particular, this implementation does not
    correspond to counting bloom filters as described eg here:
    https://en.wikipedia.org/wiki/Counting_Bloom_filter

    In order to emphasize the use of counters as a time-based garbage
    collection mechanism, we call this implementation a generational bloom
    filter.
 ��Y11�njm@@@@@@@��onn@@�@���Р&create��% H���& H�@���$hash��@��!a��1 I�2 I@@@����%bytes��9 I�: I@@�@@@�@@@���&hashes����#int��G J&�H J)@@�@@@���*index_bits����#int��T K-:�U K-=@@�@@@���.countdown_bits����#int��a LAR�b LAU@@�@@@����!t��j MY^�k MY_@���!a��q MY[�r MY]@@@@�	@@@��u LAC@@@��w K-/@@@��y J@@@��{ I@@@@���pH�������
  y [create ~hash ~hashes ~index_bits ~countdown_bits] creates an
    initially empty generational bloom filter. The number of
    generations is [2^countdown_bits]. The filter is an array of
    [2^index_bits] countdown cells, each of size [countdown_bits].
    The resulting filter takes [2^index_bits * countdown_bits] bits
    in memory. The hash function must return enough bytes to represent
    [hashes] indexes of [index_bits] bits.

    When a value is [add]ed, its [hash] is split into [hashes] chunks of
    [index_bits], that are used as indexes in the filter's countdown
    array. These countdown cells are then set to their maximum value,
    that is [2^countdown_bits-1].

    The value will remain a [mem]ber for as long as all these cells
    are above zero, which in the most optimistic case (where no
    collision occur) is until [countdown] has been called
    [2^countdown_bits-1] times. An exception is if [clear] is called,
    in which case it is certain to disappear, as all other values.

    Arguments to [create] are subject to the following constraints:
    - [0 < index_bits <= 24]
    - [0 < countdown_bits <= 24]
 ���qyy�� G��@@@@@@@��� H��!@�"@���Р#mem��� P���� P��@��@����!t��� P���� P��@���!a��� P���� P��@@@@�	@@@��@��!a��� P���� P��@@@����$bool��� P���� P��@@�@@@�@@@�@@@@������������	D Check if the value is still considered in the set (see {!create}). ��� Oaa�� Oa�@@@@@@@��� P��@�@���Р#add��� S���� S� @��@����!t��� S��� S�@���!a��� S��� S�@@@@�	@@@��@��!a��� S��� S�@@@����$unit��� S��� S�@@�@@@�@@@�@@@@����Ɛ������	* Add a member to the set (see {!create}). �� R��� R��@@@@@@@��	 S��@�@���Р#rem�� W{� W{�@��@����!t�� W{�� W{�@���!a��# W{��$ W{�@@@@�	@@@��@��!a��, W{��- W{�@@@����$unit��4 W{��5 W{�@@�@@@�@@@�@@@@���-�������	^ Force removing an element, which may remove others in case of collisions.
    Use with care. ��E U�F Vez@@@@@@@��H W{{@�@���Р)countdown��Q Z���R Z��@��@����!t��[ Z���\ Z��@���!a��b Z���c Z��@@@@�	@@@����$unit��k Z���l Z��@@�@@@�@@@@���c;�������	@ Decrement all the countdowns cells of the set (see {!create}). ��{ Y���| Y��@@@@@@@��~ Z��@�@���Р%clear��� ]�� ]#@��@����!t��� ])�� ]*@���!a��� ]&�� ](@@@@�	@@@����$unit��� ].�� ]2@@�@@@�@@@@����q�������7 Clear the entire set. ��� \���� \�@@@@@@@��� ]@�@���Р/fill_percentage��� `z~�� `z�@��@����!t��� `z��� `z�@���!a��� `z��� `z�@@@@�	@@@����%float��� `z��� `z�@@�@@@�@@@@������������	@ Percentage (in the [0;1] interval) of cells which are nonzero. ��� _44�� _4y@@@@@@@��� `zz@�@���Р9life_expectancy_histogram��� c���� c�@��@����!t��� c��� c�@���!a�� c�� c�@@@@�	@@@����%array�� c�� c�@�����#int�� c�� c�@@�@@@@�@@@�@@@@���琠�����	I Histogram of life expectancies (measured in number of countdowns to 0). ��' b���( b��@@@@@@@��* c��@�@���Р,approx_count��3 i���4 i��@��@����!t��= i���> i��@���!a��D i���E i��@@@@�	@@@����#int��M i� �N i�@@�@@@�@@@@���E�������	� Over-approximation of the number of elements added in the filter that have not expired.

    This is exact if rem is never used and over approximated otherwise
   (rem are not decounted) . ��] e!!�^ h��@@@@@@@��` i��@�@@