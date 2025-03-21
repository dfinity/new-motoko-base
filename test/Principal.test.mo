import Principal "../src/Principal";
import Blob "../src/Blob";
import { suite; test; expect } "mo:test";

let principal1 = Principal.fromText("un4fu-tqaaa-aaaab-qadjq-cai");
let defaultAccount1 : Blob = "\57\4E\66\E1\B5\DD\EF\EA\78\73\6B\E4\6C\4F\61\21\31\98\88\90\08\2E\E8\0F\97\F6\B6\DB\ED\72\84\1E";
let subAccount1 : Blob = "\4A\8D\3F\2B\6E\01\C8\7D\9E\03\B4\56\7C\F8\9A\01\D2\34\56\78\9A\BC\DE\F0\12\34\56\78\9A\BC\DE\F0";
let accountWithSubAccount1 : Blob = "\8C\5C\20\C6\15\3F\7F\51\E2\0D\0F\0F\B5\08\51\5B\47\65\63\A9\62\B4\A9\91\5F\4F\02\70\8A\ED\4F\82";

let principal2 = Principal.fromText("ylia2-w3sds-lgwx6-swrzr-xctdp-2rukx-uothy-yh5te-i5rt6-fqg62-iae");
let defaultAccount2 : Blob = "\CA\04\B1\21\82\A1\6F\55\59\D0\63\BB\F4\46\CB\A2\F8\49\51\FE\1D\13\7C\E7\D7\45\85\1B\B2\96\6E\08";
let subAccount2 : Blob = "\4F\8B\12\A5\C3\E6\07\D9\1F\A2\B0\C4\67\E8\90\23\4A\B6\5D\C8\91\0E\F2\47\8A\CD\56\B3\9E\01\2F\84";
let accountWithSubAccount2 : Blob = "\D4\40\35\AF\5D\1D\6A\37\5F\F6\26\E6\9E\17\FA\44\B3\9C\31\FE\17\D3\3A\54\FF\4C\E4\C6\F0\FA\DA\EC";

suite(
  "toLedgerAccount",
  func() {
    test(
      "default sub-account 1",
      func() {
        expect.blob(Principal.toLedgerAccount(principal1, null)).equal(defaultAccount1)
      }
    );

    test(
      "with sub-account 1",
      func() {
        expect.blob(Principal.toLedgerAccount(principal1, ?subAccount1)).equal(accountWithSubAccount1)
      }
    );

    test(
      "default sub-account 2",
      func() {
        expect.blob(Principal.toLedgerAccount(principal2, null)).equal(defaultAccount2)
      }
    );

    test(
      "with sub-account 2",
      func() {
        expect.blob(Principal.toLedgerAccount(principal2, ?subAccount2)).equal(accountWithSubAccount2)
      }
    )
  }
);

suite(
  "isCanister",
  func() {
    test(
      "returns true for opaque ids (typically canister principals)",
      func() {
        assert Principal.isCanister(Principal.fromText("rwlgt-iiaaa-aaaaa-aaaaa-cai"));
        assert Principal.isCanister(Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai"));
        assert Principal.isCanister(Principal.fromText("ryjl3-tyaaa-aaaaa-aaaba-cai"));
        assert Principal.isCanister(Principal.fromText("yoizw-hyaaa-aaaab-qacea-cai"));
        assert Principal.isCanister(Principal.fromText("n4mvt-mqaaa-aaaap-ahmzq-cai"));
        assert Principal.isCanister(Principal.fromText("2daxo-giaaa-aaaap-anvca-cai"));
        assert Principal.isCanister(Principal.fromText("i663v-bqaaa-aaaar-qaheq-cai"))
      }
    );

    test(
      "returns false for the management canister",
      func() {
        assert not Principal.isCanister(Principal.fromText("aaaaa-aa"))
      }
    );

    test(
      "returns false for the anonymous principal",
      func() {
        assert not Principal.isCanister(Principal.fromText("2vxsx-fae"))
      }
    );

    test(
      "returns false for self-authenticating ids (typically user principals)",
      func() {
        assert not Principal.isCanister(Principal.fromText("6rgy7-3uukz-jrj2k-crt3v-u2wjm-dmn3t-p26d6-ndilt-3gusv-75ybk-jae"));
        assert not Principal.isCanister(Principal.fromText("u2raz-tjwf4-cj7t5-7j5yd-cnqna-yj3z4-mohwc-hfve3-fidzp-fnd5u-eae"));
        assert not Principal.isCanister(Principal.fromText("rvulb-jedtr-5esx3-xth6u-evhyu-evngq-4ftg3-ldbwr-qdxkk-mdi5z-nqe"));
        assert not Principal.isCanister(Principal.fromText("l3e24-yowsz-w7lez-3gsgl-2tpob-z5kov-xwtuo-ap3vj-4pxee-2hhbt-vqe"));
        assert not Principal.isCanister(Principal.fromText("a6bxj-cy5lv-vrl22-5hesn-br6t5-4gjtt-ch2pe-vmeth-72u23-7sad4-iqe"));
        assert not Principal.isCanister(Principal.fromText("eqhzi-tc2i7-ge4gn-nqdho-eg5qo-tian6-55tr3-u4csn-mlzqn-cxan2-mqe"))
      }
    );

    test(
      "returns false for reserved principals",
      func() {
        assert not Principal.isCanister(Principal.fromText("sfgyh-vddpf-rwyzl-pobzx-izlbn-unwyz-s5aym-nellq-yhkzl-nnx4f-yh6"));
        assert not Principal.isCanister(Principal.fromText("bnffp-h3dpf-rwyzl-pobzx-izlbn-unwyz-3gb2u-ngoey-64bzq-fl5xm-jh6"));
        assert not Principal.isCanister(Principal.fromText("qlxgs-zldpf-rwyzl-pobzx-izlbn-uowyl-gdlpd-vig4g-adn7z-xmfl6-nx6"));
        assert not Principal.isCanister(Principal.fromText("4ji6x-kldpf-rwyzl-pobzx-izlbn-uoxhr-owz77-gtxm2-b26co-rgns7-vx6"))
      }
    )
  }
);

suite(
  "isSelfAuthenticating",
  func() {
    test(
      "returns false for opaque ids (typically canister principals)",
      func() {
        assert not Principal.isSelfAuthenticating(Principal.fromText("rwlgt-iiaaa-aaaaa-aaaaa-cai"));
        assert not Principal.isSelfAuthenticating(Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai"));
        assert not Principal.isSelfAuthenticating(Principal.fromText("ryjl3-tyaaa-aaaaa-aaaba-cai"));
        assert not Principal.isSelfAuthenticating(Principal.fromText("yoizw-hyaaa-aaaab-qacea-cai"));
        assert not Principal.isSelfAuthenticating(Principal.fromText("n4mvt-mqaaa-aaaap-ahmzq-cai"));
        assert not Principal.isSelfAuthenticating(Principal.fromText("2daxo-giaaa-aaaap-anvca-cai"));
        assert not Principal.isSelfAuthenticating(Principal.fromText("i663v-bqaaa-aaaar-qaheq-cai"))
      }
    );

    test(
      "returns false for the management canister",
      func() {
        assert not Principal.isSelfAuthenticating(Principal.fromText("aaaaa-aa"))
      }
    );

    test(
      "returns false for the anonymous principal",
      func() {
        assert not Principal.isSelfAuthenticating(Principal.fromText("2vxsx-fae"))
      }
    );

    test(
      "returns true for self-authenticating ids (typically user principals)",
      func() {
        assert Principal.isSelfAuthenticating(Principal.fromText("6rgy7-3uukz-jrj2k-crt3v-u2wjm-dmn3t-p26d6-ndilt-3gusv-75ybk-jae"));
        assert Principal.isSelfAuthenticating(Principal.fromText("u2raz-tjwf4-cj7t5-7j5yd-cnqna-yj3z4-mohwc-hfve3-fidzp-fnd5u-eae"));
        assert Principal.isSelfAuthenticating(Principal.fromText("rvulb-jedtr-5esx3-xth6u-evhyu-evngq-4ftg3-ldbwr-qdxkk-mdi5z-nqe"));
        assert Principal.isSelfAuthenticating(Principal.fromText("l3e24-yowsz-w7lez-3gsgl-2tpob-z5kov-xwtuo-ap3vj-4pxee-2hhbt-vqe"));
        assert Principal.isSelfAuthenticating(Principal.fromText("a6bxj-cy5lv-vrl22-5hesn-br6t5-4gjtt-ch2pe-vmeth-72u23-7sad4-iqe"));
        assert Principal.isSelfAuthenticating(Principal.fromText("eqhzi-tc2i7-ge4gn-nqdho-eg5qo-tian6-55tr3-u4csn-mlzqn-cxan2-mqe"))
      }
    );

    test(
      "returns false for reserved principals",
      func() {
        assert not Principal.isSelfAuthenticating(Principal.fromText("sfgyh-vddpf-rwyzl-pobzx-izlbn-unwyz-s5aym-nellq-yhkzl-nnx4f-yh6"));
        assert not Principal.isSelfAuthenticating(Principal.fromText("bnffp-h3dpf-rwyzl-pobzx-izlbn-unwyz-3gb2u-ngoey-64bzq-fl5xm-jh6"));
        assert not Principal.isSelfAuthenticating(Principal.fromText("qlxgs-zldpf-rwyzl-pobzx-izlbn-uowyl-gdlpd-vig4g-adn7z-xmfl6-nx6"));
        assert not Principal.isSelfAuthenticating(Principal.fromText("4ji6x-kldpf-rwyzl-pobzx-izlbn-uoxhr-owz77-gtxm2-b26co-rgns7-vx6"))
      }
    )
  }
);

suite(
  "isReserved",
  func() {
    test(
      "returns false for opaque ids (typically canister principals)",
      func() {
        assert not Principal.isReserved(Principal.fromText("rwlgt-iiaaa-aaaaa-aaaaa-cai"));
        assert not Principal.isReserved(Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai"));
        assert not Principal.isReserved(Principal.fromText("ryjl3-tyaaa-aaaaa-aaaba-cai"));
        assert not Principal.isReserved(Principal.fromText("yoizw-hyaaa-aaaab-qacea-cai"));
        assert not Principal.isReserved(Principal.fromText("n4mvt-mqaaa-aaaap-ahmzq-cai"));
        assert not Principal.isReserved(Principal.fromText("2daxo-giaaa-aaaap-anvca-cai"));
        assert not Principal.isReserved(Principal.fromText("i663v-bqaaa-aaaar-qaheq-cai"))
      }
    );

    test(
      "returns false for the management canister",
      func() {
        assert not Principal.isReserved(Principal.fromText("aaaaa-aa"))
      }
    );

    test(
      "returns false for the anonymous principal",
      func() {
        assert not Principal.isReserved(Principal.fromText("2vxsx-fae"))
      }
    );

    test(
      "returns false for self-authenticating ids (typically user principals)",
      func() {
        assert not Principal.isReserved(Principal.fromText("6rgy7-3uukz-jrj2k-crt3v-u2wjm-dmn3t-p26d6-ndilt-3gusv-75ybk-jae"));
        assert not Principal.isReserved(Principal.fromText("u2raz-tjwf4-cj7t5-7j5yd-cnqna-yj3z4-mohwc-hfve3-fidzp-fnd5u-eae"));
        assert not Principal.isReserved(Principal.fromText("rvulb-jedtr-5esx3-xth6u-evhyu-evngq-4ftg3-ldbwr-qdxkk-mdi5z-nqe"));
        assert not Principal.isReserved(Principal.fromText("l3e24-yowsz-w7lez-3gsgl-2tpob-z5kov-xwtuo-ap3vj-4pxee-2hhbt-vqe"));
        assert not Principal.isReserved(Principal.fromText("a6bxj-cy5lv-vrl22-5hesn-br6t5-4gjtt-ch2pe-vmeth-72u23-7sad4-iqe"));
        assert not Principal.isReserved(Principal.fromText("eqhzi-tc2i7-ge4gn-nqdho-eg5qo-tian6-55tr3-u4csn-mlzqn-cxan2-mqe"))
      }
    );

    test(
      "returns true for reserved principals",
      func() {
        assert Principal.isReserved(Principal.fromText("sfgyh-vddpf-rwyzl-pobzx-izlbn-unwyz-s5aym-nellq-yhkzl-nnx4f-yh6"));
        assert Principal.isReserved(Principal.fromText("bnffp-h3dpf-rwyzl-pobzx-izlbn-unwyz-3gb2u-ngoey-64bzq-fl5xm-jh6"));
        assert Principal.isReserved(Principal.fromText("qlxgs-zldpf-rwyzl-pobzx-izlbn-uowyl-gdlpd-vig4g-adn7z-xmfl6-nx6"));
        assert Principal.isReserved(Principal.fromText("4ji6x-kldpf-rwyzl-pobzx-izlbn-uoxhr-owz77-gtxm2-b26co-rgns7-vx6"))
      }
    )
  }
)
