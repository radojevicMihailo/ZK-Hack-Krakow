import { bytesToBigInt, fromHex } from "@zk-email/helpers/dist/binaryFormat";
import { generateEmailVerifierInputs } from "@zk-email/helpers/dist/input-generators";

export const STRING_PRESELECTOR = "";

export type IActivityCircuitInputs = {
  activityIndex: string;
  address: string;
  emailHeader: string[];
  emailHeaderLength: string;
  pubkey: string[];
  signature: string[];
  emailBody?: string[] | undefined;
  emailBodyLength?: string | undefined;
  precomputedSHA?: string[] | undefined;
  bodyHashIndex?: string | undefined;
  old_activity_score: string;
};

export async function generateActivityVerifierCircuitInputs(
  email: string | Buffer,
  ethereumAddress: string
): Promise<IActivityCircuitInputs> {
  const emailVerifierInputs = await generateEmailVerifierInputs(email, {
    shaPrecomputeSelector: STRING_PRESELECTOR,
  });

  const bodyRemaining = emailVerifierInputs.emailBody!.map((c) => Number(c)); // Char array to Uint8Array
  const selectorBuffer = Buffer.from(STRING_PRESELECTOR);
  const activityIndex =
    Buffer.from(bodyRemaining).indexOf(selectorBuffer) + selectorBuffer.length;

  const address = bytesToBigInt(fromHex(ethereumAddress)).toString();
  const old_activity_score = 50;

  return {
    ...emailVerifierInputs,
    activityIndex: activityIndex.toString(),
    address,
    old_activity_score: old_activity_score.toString(),
  };
}
