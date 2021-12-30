let input_x = (0xe406000000000000000000000000000000000000000000000000000000000000 : bls12_381_fr)
let input_y = (0x0100000000000000000000000000000000000000000000000000000000000000 : bls12_381_fr)
let proof_a = (0x1257c93c134569fd00c974eb4c0b89ad03dcb847da743622adfc76c06ba466bf6bd7a5f03d5efe51b4bae216c27ec8500a2a0e34b9945a1bf73f4b8482fe3d27c8fb4c9f55b9a6e2e5d072406b58b6658984cc8dc543cb15723f6cce4b0b5403 : bls12_381_g1)
let proof_b = (0x12fbfb6613623790449bf0df2d0684997f19fc853b7ac3f6ef6db04f1925ddd3f9123803fbece8742594afd834ac86e6002c7b074d732c96bd2c2a25d2148b3a58f70adc8d3478026c1c4dcf618342a84c620a87254d09820dab8594b2a523380e343fa41d631a32592fa87aa8b49ae22b5ea95eb612c326028554976b0c9ef0716852f708e11da2cb583de2e62a4d6a0adfa5ed6a5cadfc83341affa3c81d5b02f287723f5c275089c9a8a9fbacfc57384169d252f3a2fc7110e0f7add72f10 : bls12_381_g2)
let proof_c = (0x13604b5279f87bf225635880611e1ddfda360c032ce317d57c47bb139fd96d6884dc64f890b37c45648019095e1f494918df862a1309efede2e15a83e6bfef2ac3903278f75648cff088fdba0ed1b1493b3e8b9e79599c624890bf56de3d28bc : bls12_381_g1)

let alpha = (0x024142bc89bf29017a38d0ee97711098639aa0bbc5b54b5104cc88b1c0fd09330fb8341e3da91e7a50f0da5c988517db0f52df51f745392ecdd3ffbb50f8a25fcdec6f48886b650de26821e244cb8ab69d49722d290a420ce1284b909d3e15a0 : bls12_381_g1)
let beta = (0x0050b3ab4877c99ce7f180e879d91eb4df24b1e20ed88f1fdde42f91dfe0e7e451aa35d1457dd15ab507fc8f2b3180550ca7b4ea9b67810e346456c35060c8d542f37ee5fe2b1461e2f02fefac55a9863e94cab5c16befad3b866a42ee20835b1351f3f9c20a05586c1d647d756efb5c575d7ab23fbf5b3e1a6ffe024633a63a668a01fcab440866035ea2c0d4bfe30a1242f67119650e2aa605289ade2684287192382d6a01d7865fcd9e1507264a80f387b6441e37438c888159827a4efa67 : bls12_381_g2)
let gamma = (0x0de8089c146675c162fc5c77aa880433ca0f9add40f37abf8996bacfca6b905403054a4ee1be18124c3217563db2811617021d4c9687b8ec6817958160a3131b801a7a69629838aaca5f9f1b345fb8ce2acaa8399f2e6e0e10d02848981dd4a4145afc519008f1da147fb6e676b1a2539ae45aa0912176a4f088f12865cd14add2c85536ef5d6b934c4a6b8fe81f57d215aac5183487aa76205f96456a49ba73a7f6d3947ee0e487c972ddfe70b60f96753ba00435efd1e8c7207c98553c0bbe : bls12_381_g2)
let delta = (0x0e0599e79d32db0cddd7e9b7891125bdf5317f50836a7d01054cc9f9b21967c2b4cc834ad51fb712acaeeeaa61e186bc09cd3da7964a919c03f81fa75140ad2cce52885b3b488155564c07170fccf41a8eb8913a83d867814f46dd055b3b13a40c93acb46c2159252649ed21e2165775e16237348ed65d60b27c2caf2e98b37bde7922d6a89b7b629d080d7f57b823f11495b9c195dc357705f92f377b371de690da0b076d8ddc157b1fa459b13fda741df9fc8935fbf6716b00671dec6270db : bls12_381_g2)
let gamma_abc = ((0x0af10ee82fcec5230ab73b92e85c24e58f4fe86a92e4436ebbbc8e5d462b47fe12bb71e63828fcd3b414ba9d67590a3603698ee10b387349b12c466d7122817044152cae74c6f92e7a4bc9f40f4c40bd295dc4b5a64e942fc422df832eb1b241 : bls12_381_g1) , (0x05f5f6ad7cdd60846eb106f5c59ee23a0938c1b305a736d3ba5d13d5aa597077927e9f01bdbebabd389ec26d5a7727db0ef1a2fd3e0d297ac619a65227395a907980ff50ac38fd39d14af08bcb10be352453ab12d203c4879bdb984502202e40 : bls12_381_g1) , (0x0d1fbf64c2f2007b8d7801aeb68a4f627d3172c03da4d3c26e20e9dc5ca08f723fc53f07e40de6fa645aadd6e4e627611638a92ac3abc2147e7122e9a26332bedd5e173e282153e7391fa89afe0b61fc040372e52d6793fabe9f63f1b1acfcd7 : bls12_381_g1))

let test =
  let t = gamma_abc.1 * input_x + gamma_abc.2 * input_y + gamma_abc.0 in
  assert (Tezos.pairing_check [(proof_a, proof_b); (-t, gamma); (-proof_c, delta); (-alpha, beta)])
