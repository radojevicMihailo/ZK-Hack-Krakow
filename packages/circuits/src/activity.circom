pragma circom 2.1.5;

include "@zk-email/zk-regex-circom/circuits/common/from_addr_regex.circom";
include "@zk-email/circuits/email-verifier.circom";
include "@zk-email/circuits/utils/regex.circom";
include "./regex-liquidated.circom";
include "./regex-profit.circom";

template ActivityVerifier(maxHeadersLength, maxBodyLength, n, k, exposeFrom) {
    assert(exposeFrom < 2);

    signal input emailHeader[maxHeadersLength];
    signal input emailHeaderLength;
    signal input pubkey[k];
    signal input signature[k];
    signal input emailBody[maxBodyLength];
    signal input emailBodyLength;
    signal input bodyHashIndex;
    signal input precomputedSHA[32];
    signal input activityIndex;
    signal input address; // we don't need to constrain the + 1 due to https://geometry.xyz/notebook/groth16-malleability
    signal input old_activity_score;

    signal output pubkeyHash;
    signal output new_activity_score;
    signal output profit;


    component EV = EmailVerifier(maxHeadersLength, maxBodyLength, n, k, 0);
    EV.emailHeader <== emailHeader;
    EV.pubkey <== pubkey;
    EV.signature <== signature;
    EV.emailHeaderLength <== emailHeaderLength;
    EV.bodyHashIndex <== bodyHashIndex;
    EV.precomputedSHA <== precomputedSHA;
    EV.emailBody <== emailBody;
    EV.emailBodyLength <== emailBodyLength;

    pubkeyHash <== EV.pubkeyHash;

    if (exposeFrom) {
        signal input fromEmailIndex;

        signal (fromEmailFound, fromEmailReveal[maxHeadersLength]) <== FromAddrRegex(maxHeadersLength)(emailHeader);
        fromEmailFound === 1;

        var maxEmailLength = 255;

        signal output fromEmailAddrPacks[9] <== PackRegexReveal(maxHeadersLength, maxEmailLength)(fromEmailReveal, fromEmailIndex);
    }


    signal (profitFound, profitReveal[maxBodyLength]) <== ProfitRegex(maxBodyLength)(emailBody);
    signal (liquidatedFound, liquidatedReveal[maxBodyLength]) <== LiquidatedRegex(maxBodyLength)(emailBody);
    profitFound + liquidatedFound === 1;
   
    signal tmp1;
    signal tmp2;
    tmp1 <== profitFound * 30;
    tmp2 <== liquidatedFound * 15;
    new_activity_score <== old_activity_score + tmp1 - tmp2;
}


component main { public [ address ] } = ActivityVerifier(1024, 1536, 121, 17, 0);