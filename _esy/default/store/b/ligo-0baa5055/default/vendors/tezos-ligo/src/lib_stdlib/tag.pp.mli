Caml1999N029����   +         	)vendors/tezos-ligo/src/lib_stdlib/tag.mli����  E�  �  39  1������1ocaml.ppx.context��&_none_@@ �A����������)tool_name���*ppx_driver@@@����,include_dirs����"[]@@@����)load_path!����
%@%@@����,open_modules*����.@.@@����+for_package3����$None8@8@@����%debug=����%falseB@B@@����+use_threadsG����
K@K@@����-use_vmthreadsP����T@T@@����/recursive_typesY����]@]@@����)principalb����%f@f@@����3transparent_modulesk����.o@o@@����-unboxed_typest����7x@x@@����-unsafe_string}����@�@�@@����'cookies�����"::�����������,inline_tests�@�@@����(disabled��.<command-line>A@A�A@I@@��A@@�A@J@@@@�@@����������������,library-name�@�@@����,tezos_stdlib��A@A�A@M@@��A@N@@@@�@@�������@�@@@�@@�@@@�@@�@@@@�@@@�@�������*ocaml.textǐ������
  � Tags and tag sets.  Tags are basically similar to a plain extensible
    variant type, but wrapped with metadata that enables them to be printed
    generically and combined into tag sets where each tag is either not
    present or associated with a specific value.

    They are primarily intended for use with the `Logging` module but it
    would probably be reasonable to use them for other purposes. ��	)vendors/tezos-ligo/src/lib_stdlib/tag.mliZ���`�	@@@@@@���A�    �#def��d	�	��d	�	�@���@��d	�	��d	�	�@@@�BA@@@A@���)ocaml.doc萠�����	j Type of tag definitions.  Analogous to a constructor of an extensible
    variant type, but first-class. ��!b		�"c	h	�@@@@@@@��$d	�	�@@�@���Р#def��-lLP�.lLS@���#doc����&string��9lL[�:lLa@@�@@@��@����&string��DlLe�ElLk@@�@@@��@��@�����&Format)formatter��SlLp�TlL�@@�@@@��@��!a��\lL��]lL�@@@����$unit��dlL��elL�@@�@@@�@@@�@@@����#def��olL��plL�@���!a��vlL��wlL�@@@@�	@@@��zlLo@@@�8@@@��}lLV@@@@���jQ�������
  � Define a new tag with a name, printer, and optional documentation string.
    This is generative, not applicative, so tag definitions created with
    identical names and printers at different times or places will be
    different tags!  You probably do not want to define a tag in a local
    scope unless you have something really tricky in mind.  Basically all
    the caveats you would have if you wrote [type t +=] apply. ���f	�	���k
K@@@@@@@���lLL@�@���Р$name���n����n��@��@����#def���n����n��@���!a���n����n��@@@@�	@@@����&string���n����n��@@�@@@�@@@@@���n��@�@���Р#doc���p����p��@��@����#def���p����p��@���!a���p����p��@@@@�	@@@����&string���p����p��@@�@@@�@@@@@���p��@�@���Р'printer���r����r��@��@����#def���r����r��@���!a���r����r��@@@@�	@@@��@�����&Format)formatter��r���r��@@�@@@��@��!a��r� �r�@@@����$unit��r��r�
@@�@@@�@@@�@@@�$@@@@@��r��@�@���Р&pp_def��%u7;�&u7A@��@�����&Format)formatter��1u7D�2u7T@@�@@@��@����#def��<u7[�=u7^@���!a��Cu7X�Du7Z@@@@�	@@@����$unit��Lu7b�Mu7f@@�@@@�@@@� @@@@���=$�������	% Print the name of a tag definition. ��]t�^t6@@@@@@@��`u77@�@���A�    �!t��jy���ky��@@@��Р!V��ry� �sy�@������#def��|y��}y�
@���!a���y���y�@@@@�	@@@���!a���y���y�@@@@�����!t���y���y�@@�@@@�&@@@A@����k�������	� A binding consisting of a tag and value.  If a `def` is a constructor
    of an extensible variant type, a `t` is a value of that type. ���whh��x��@@@@@@@���y��@@�@���Р"pp���{��{@��@�����&Format)formatter���{��{/@@�@@@��@����!t���{3��{4@@�@@@����$unit���{8��{<@@�@@@�@@@�@@@@@���{@�@������#Key���}>E��}>H@�����A�    �!t���~OV��~OW@@@��Р!V���~OZ��~O[@������#def���~Oa��~Od@���!a��~O^�~O`@@@@�	@@@@�����!t��~Oh�~Oi@@�@@@�@@@A@@��~OQ@@�@@��}>K�jm@@@��}>>@�@���A�    �#set��$ G��% G�@@@@A@�����������
  � Tag sets.  If `t` is an extensible variant type, `set` is a set of `t`s
    no two of which have the same constructor.  Most ordinary set and map
    operations familiar from the OCaml standard library are provided.
    `equal` and `compare` are purposely not provided as there is no
    meaningful ordering on tags and their arguments may not even have a
    meaningful notion of equality. ��2 Aoo�3 F��@@@@@@@��5 G��@@�@���Р%empty��> I�? I@����#set��F I�G I@@�@@@@@��J I@�@���Р(is_empty��S K�T K$@��@����#set��] K'�^ K*@@�@@@����$bool��f K.�g K2@@�@@@�@@@@@��k K@�@���Р#mem��t M48�u M4;@��@����#def��~ M4A� M4D@���!a��� M4>�� M4@@@@@�	@@@��@����#set��� M4H�� M4K@@�@@@����$bool��� M4O�� M4S@@�@@@�@@@�@@@@@��� M44@�@���Р#add��� OUY�� OU\@��@����#def��� OUb�� OUe@���!a��� OU_�� OUa@@@@�	@@@��@��!a��� OUi�� OUk@@@��@����#set��� OUo�� OUr@@�@@@����#set��� OUv�� OUy@@�@@@�@@@�@@@�"@@@@@��� OUU@�@���Р&update��� Q{�� Q{�@��@����#def��� Q{��� Q{�@���!a��� Q{��� Q{�@@@@�	@@@��@��@����&option�� Q{�� Q{�@���!a��
 Q{�� Q{�@@@@�	@@@����&option�� Q{�� Q{�@���!a�� Q{�� Q{�@@@@�	@@@�
@@@��@����#set��& Q{��' Q{�@@�@@@����#set��/ Q{��0 Q{�@@�@@@�@@@��4 Q{�@@@�@@@@@@��7 Q{{@�	@���Р)singleton��@ S���A S��@��@����#def��J S���K S��@���!a��Q S���R S��@@@@�	@@@��@��!a��Z S���[ S��@@@����#set��b S���c S��@@�@@@�@@@�@@@@@��h S��@�@���Р&remove��q U���r U��@��@����#def��{ U���| U��@���!a��� U���� U��@@@@�	@@@��@����#set��� U���� U��@@�@@@����#set��� U���� U� @@�@@@�@@@�@@@@@��� U��@�@���Р#rem��� W�� W	@��@����#def��� W�� W@���!a��� W�� W@@@@�	@@@��@����#set��� W�� W@@�@@@����#set��� W�� W @@�@@@�@@@�@@@@@��� W@�@���A�    �&merger��� Y"'�� Y"-@@@��Р&merger��� Y"1�� Y"7@@����!a��� Y";�� Y"<@@��@����#def��� Y"A�� Y"D@���!a��� Y">�� Y"@@@@@�	@@@��@����&option�� Y"K� Y"Q@���!a�� Y"H� Y"J@@@@�	@@@��@����&option�� Y"X� Y"^@���!a�� Y"U�  Y"W@@@@�	@@@����&option��( Y"e�) Y"k@���!a��/ Y"b�0 Y"d@@@@�	@@@�
@@@�'@@@�:@@@��6 Y":@@@�V@@@A@@��9 Y""�: Y"l@@�@���Р%merge��C [nr�D [nw@��@����&merger��M [nz�N [n�@@�@@@��@����#set��X [n��Y [n�@@�@@@��@����#set��c [n��d [n�@@�@@@����#set��l [n��m [n�@@�@@@�@@@�@@@�%@@@@@��s [nn@�@���A�    �'unioner��} ]���~ ]��@@@��Р'unioner��� ]���� ]��@@����!a��� ]���� ]��@@��@����#def��� ]���� ]��@���!a��� ]���� ]��@@@@�	@@@��@��!a��� ]���� ]��@@@��@��!a��� ]���� ]��@@@��!a��� ]���� ]��@@@�	@@@�@@@�@@@��� ]��@@@�8@@@A@@��� ]���� ]��@@�@���Р%union��� _���� _��@��@����'unioner��� _���� _��@@�@@@��@����#set��� _���� _��@@�@@@��@����#set��� _���� _��@@�@@@����#set��� _���� _��@@�@@@�@@@�@@@�%@@@@@��� _��@�@���Р$iter�� a��� a�@��@��@����!t�� a�� a�@@�@@@����$unit�� a�� a�@@�@@@�@@@��@����#set��" a��# a�@@�@@@����$unit��+ a��, a�@@�@@@�@@@��0 a�@@@@@��2 a��@�@���Р$fold��; c!%�< c!)@��@��@����!t��G c!-�H c!.@@�@@@��@��!b��P c!2�Q c!4@@@��!b��V c!8�W c!:@@@�	@@@�@@@��@����#set��b c!?�c c!B@@�@@@��@��!b��k c!F�l c!H@@@��!b��q c!L�r c!N@@@�	@@@�@@@��v c!,@@@@@��x c!!@�@���Р'for_all��� ePT�� eP[@��@��@����!t��� eP_�� eP`@@�@@@����$bool��� ePd�� ePh@@�@@@�@@@��@����#set��� ePm�� ePp@@�@@@����$bool��� ePt�� ePx@@�@@@�@@@��� eP^@@@@@��� ePP@�@���Р&exists��� gz~�� gz�@��@��@����!t��� gz��� gz�@@�@@@����$bool��� gz��� gz�@@�@@@�@@@��@����#set��� gz��� gz�@@�@@@����$bool��� gz��� gz�@@�@@@�@@@��� gz�@@@@@��� gzz@�@���Р&filter��� i���� i��@��@��@����!t�� i��� i��@@�@@@����$bool��
 i��� i��@@�@@@�@@@��@����#set�� i��� i��@@�@@@����#set�� i���  i��@@�@@@�@@@��$ i��@@@@@��& i��@�@���Р)partition��/ k���0 k��@��@��@����!t��; k���< k��@@�@@@����$bool��D k���E k��@@�@@@�@@@��@����#set��P k���Q k��@@�@@@�������#set��\ k���] k��@@�@@@�����#set��f k���g k��@@�@@@@�@@@�@@@��l k��@@@@@��n k��@�	@���Р(cardinal��w m� �x m�@��@����#set��� m��� m�@@�@@@����#int��� m��� m�@@�@@@�@@@@@��� m��@�@���Р+min_binding��� o�� o&@��@����#set��� o)�� o,@@�@@@����!t��� o0�� o1@@�@@@�@@@@@��� o@�@���Р/min_binding_opt��� q37�� q3F@��@����#set��� q3I�� q3L@@�@@@����&option��� q3R�� q3X@�����!t��� q3P�� q3Q@@�@@@@�@@@�@@@@@��� q33@�@���Р+max_binding��� sZ^�� sZi@��@����#set��� sZl�� sZo@@�@@@����!t��� sZs�� sZt@@�@@@�@@@@@��� sZZ@�@���Р/max_binding_opt�� uvz� uv�@��@����#set�� uv�� uv�@@�@@@����&option�� uv�� uv�@�����!t��! uv��" uv�@@�@@@@�@@@�@@@@@��' uvv@�@���Р&choose��0 w���1 w��@��@����#set��: w���; w��@@�@@@����!t��C w���D w��@@�@@@�@@@@@��H w��@�@���Р*choose_opt��Q y���R y��@��@����#set��[ y���\ y��@@�@@@����&option��d y���e y��@�����!t��m y���n y��@@�@@@@�@@@�@@@@@��s y��@�@���Р%split��| {���} {��@��@����#def��� {���� {��@���!a��� {���� {��@@@@�	@@@��@����#set��� {���� {��@@�@@@�������#set��� {���� {��@@�@@@�����&option��� {���� {�@���!a��� {���� {��@@@@�	@@@�����#set��� {��� {�@@�@@@@�@@@�,@@@�8@@@@@��� {��@�@���Р(find_opt��� }
�� }
@��@����#def��� }
�� }
@���!a��� }
�� }
@@@@�	@@@��@����#set��� }
#�� }
&@@�@@@����&option��� }
-�� }
3@���!a��� }
*�� }
,@@@@�	@@@�
@@@� @@@@@�� }

@�@���Р$find��
 59� 5=@��@����#def�� 5C� 5F@���!a�� 5@� 5B@@@@�	@@@��@����#set��& 5J�' 5M@@�@@@����&option��/ 5T�0 5Z@���!a��6 5Q�7 5S@@@@�	@@@�
@@@� @@@@@��< 55@�@���Р#get��E �\`�F �\c@��@����#def��O �\i�P �\l@���!a��V �\f�W �\h@@@@�	@@@��@����#set��a �\p�b �\s@@�@@@��!a��h �\w�i �\y@@@�
@@@�@@@@@��m �\\@�@���Р*find_first��v �{�w �{�@��@��@�����#Key!t��� �{��� �{�@@�@@@����$bool��� �{��� �{�@@�@@@�@@@��@����#set��� �{��� �{�@@�@@@����!t��� �{��� �{�@@�@@@�@@@��� �{�@@@@@��� �{{@�@���Р.find_first_opt��� ����� ���@��@��@�����#Key!t��� ����� ���@@�@@@����$bool��� ����� ���@@�@@@�@@@��@����#set��� ����� ���@@�@@@����&option��� ����� ���@�����!t��� ����� ���@@�@@@@�@@@�@@@��� ���@@@@@��� ���@�@���Р)find_last��� ����� ���@��@��@�����#Key!t��	 ����	 ���@@�@@@����$bool��	 ����	 �� @@�@@@�@@@��@����#set��	 ���	 ��@@�@@@����!t��	$ ���	% ��@@�@@@�@@@��	) ���@@@@@��	+ ���@�@���Р-find_last_opt��	4 ��	5 � @��@��@�����#Key!t��	B �$�	C �)@@�@@@����$bool��	K �-�	L �1@@�@@@�@@@��@����#set��	W �6�	X �9@@�@@@����&option��	` �?�	a �E@�����!t��	i �=�	j �>@@�@@@@�@@@�@@@��	o �#@@@@@��	q �@�@���Р#map��	z �GK�	{ �GN@��@��@����!t��	� �GR�	� �GS@@�@@@����!t��	� �GW�	� �GX@@�@@@�@@@��@����#set��	� �G]�	� �G`@@�@@@����#set��	� �Gd�	� �Gg@@�@@@�@@@��	� �GQ@@@@@��	� �GG@�@���Р$mapi��	� �im�	� �iq@��@��@����!t��	� �iu�	� �iv@@�@@@����!t��	� �iz�	� �i{@@�@@@�@@@��@����#set��	� �i��	� �i�@@�@@@����#set��	� �i��	� �i�@@�@@@�@@@��	� �it@@@@@��	� �ii@�@���Р&pp_set��	� ����	� ���@��@�����&Format)formatter��	� ����	� ���@@�@@@��@����#set��
 ����
 ���@@�@@@����$unit��
 ����
 ���@@�@@@�@@@�@@@@@��
 ���@�@������#DSL��
 ����
 ���@�����A�    �#arg��
* ����
+ ���@���@��
0 ����
1 ���@@@�BA���@��
7 ����
8 ���@@@�BA���@��
> ����
? ���@@@�BA���@��
E ����
F ���@@@�BA@@@A@@��
I ���@@� @���Р!a��
R �4:�
S �4;@��@����#def��
\ �4A�
] �4D@���!v��
c �4>�
d �4@@@@@�	@@@��@��!v��
l �4H�
m �4J@@@����#arg��
t �4y�
u �4|@���@��@��!b��
 �4P�
� �4R@@@��@��!v��
� �4V�
� �4X@@@��!c��
� �4\�
� �4^@@@�	@@@�@@@��@��!v��
� �4c�
� �4e@@@��!d��
� �4i�
� �4k@@@�	@@@��
� �4O@@@���!b��
� �4m�
� �4o@@@���!c��
� �4q�
� �4s@@@���!d��
� �4u�
� �4w@@@@��
� �4ND@@@�NE@@@�XF@@@@���
���������	S Use a semantic tag with a `%a` format, supplying the pretty printer from the tag. ��
� ����
� ��3@@@@@@@��
� �46V@�W@���Р!s��
� ����
� ���@��@����#def��
� ����
� ���@���!v��
� ����
� ���@@@@�	@@@��@��!v��
� ����
� ���@@@����#arg��
� ����
� ��@���@��!v��
� ����
� ���@@@��!d�� ���� ���@@@�	@@@���!b�� ���� ���@@@���!c�� ���� ���@@@���!d�� ���� ���@@@@�� ���(@@@�2)@@@�<*@@@@���󐠠����	H Use a semantic tag with ordinary formats such as `%s`, `%d`, and `%f`. ��, �~��- �~�@@@@@@@��/ ���:@�;@���Р!t��8 �:@�9 �:A@��@����#def��B �:G�C �:J@���!v��I �:D�J �:F@@@@�	@@@��@��!v��R �:N�S �:P@@@����#arg��Z �:e�[ �:h@���!d��a �:U�b �:W@@@���!b��h �:Y�i �:[@@@���!c��o �:]�p �:_@@@���!d��v �:a�w �:c@@@@��y �:T@@@�) @@@�3!@@@@���hO�������	. Supply a semantic tag without formatting it. ��� ��� �9@@@@@@@��� �:<1@�2@���Р"-%��� ����� ���@��@���$tags����#set��� ����� ���@@�@@@��!a��� ����� ���@@@��� ���@@@��@����#arg��� ����� ���@���!a��� ����� ���@@@������&Format)formatter��� ����� ���@@�@@@�����$unit��� ����� ���@@�@@@���!d��� ����� ���@@@@��� ���'@@@���$tags����#set��� ����� ��@@�@@@��!d��� ���� ��@@@��� ���@@@�@@@��� ���@@@@����Ȑ������	6 Perform the actual application of a tag to a format. �� �jl� �j�@@@@@@@�� ���@�@@�� ���� �@@����ܐ������
  � DSL for logging messages.  Opening this locally makes it easy to supply a number
    of semantic tags for a log event while using their values in the human-readable
    text.  For example:

    {[
      lwt_log_info Tag.DSL.(fun f ->
          f "request for operations %a:%d from peer %a timed out."
          -% t event "request_operations_timeout"
          -% a Block_hash.Logging.tag bh
          -% s operations_index_tag n
          -% a P2p_peer.Id.Logging.tag pipeline.peer_id)
    ]} �� ���� ���@@@@@@@�� ���@�@@